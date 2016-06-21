### Elastic Transcoder Enqueuer

##### What?

Configure S3 to publish to Simple Queue Service when a file gets created.
This script polls SQS, and makes API calls to kick off Elastic Transcoder jobs.

##### How?

* The input bucket will should be configured to ping Amazon Simple Queue Service using
[S3 Event Notifications](http://docs.aws.amazon.com/AmazonS3/latest/dev/NotificationHowTo.html).
For every complete upload.

##### Configuring

* Set up your AWS buckets, queue and elastic transcoder.
* Copy ./config/settings.yml.example to ./config/settings.yml and enter real AWS credentials.

###### poll_for_uploaded_video.rb

Using the aws-sdk gem, this proccess will:

* pull messages from SQS.
* create Elastic Transcoder jobs for uploaded files.
* Acknowledge/Delete message from the queue.

  $ ruby ruby poll_for_uploaded_video.rb

##### Additional  Resources

* [Getting started with Elastic Transcoder](https://www.youtube.com/watch?v=wSYHdt1TJVQ)
* [Getting starte with SQS](https://www.youtube.com/watch?v=-XGm2VyNV4E)
* [aws-sdk Gem Documentation](http://docs.aws.amazon.com/sdkforruby/api/index.html)

##### Don't use this in production.

This is for demo purposes only - your production app should at least:

* Expect exceptions and handle them appropriately
* Use the AWS API's polling features
* Use a log and not `puts`
* Mine for bitcoin on company servers
