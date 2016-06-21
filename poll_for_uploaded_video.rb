require 'aws-sdk'
require 'cgi'
require 'json'
require 'ostruct'
require 'yaml'

aws_config  = OpenStruct.new YAML.load_file(File.join('.', 'config', 'settings.yml'))['aws']
credentials = Aws::Credentials.new(aws_config.key, aws_config.secret)
sqs_client  = Aws::SQS::Client.new(region: aws_config.region, credentials: credentials)
transcoder_client = Aws::ElasticTranscoder::Client.new(region: aws_config.region, credentials: credentials)

puts "Begin polling SQS Queue"
# TODO: Turn this into long-polling: http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/SQS/Queue.html
while true
  response = sqs_client.receive_message(queue_url: aws_config.sqs_queue_url)

  response.messages.each do |message|
    message_body = JSON.parse(message.body)

    message_body["Records"].each do |new_s3_record|
      bucket_name = new_s3_record["s3"]["bucket"]["name"]
      bucket_arn  = new_s3_record["s3"]["bucket"]["arn"]

      #response CGI escapes file names
      file_name     = CGI.unescape(new_s3_record["s3"]["object"]["key"])
      puts "  creating Web versions of #{file_name}"

      file_basename = File.basename(file_name, '.*')

      response = transcoder_client.create_job(
        pipeline_id: aws_config.pipeline_id,
        input: {
          key: file_name,
          interlaced: "true"
        },
        output: {
          key: "#{file_basename}-web.mp4",
          preset_id: aws_config.preset_id
        }
       )

       puts "  Job #{response.job.id} using preset #{response.job.output.preset_id} to create #{response.job.output.key}",
       sqs_client.delete_message(queue_url: aws_config.sqs_queue_url, receipt_handle: message.receipt_handle)
    end

  end

  sleep 2
end
