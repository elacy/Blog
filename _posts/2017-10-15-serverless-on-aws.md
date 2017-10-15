---
title: Serverless on AWS
layout: post
categories:
  - Technology
---
![](/assets/images/2017/AmazonWebservices_Logo.svg "Amazon Web Services")

I've been building a completely serverless application in AWS over the past while and I thought I'd share some of the things I learned.

This is going to be written from the perspective of a for-profit business

## Why serverless?
The cost of building and maintaining any application is huge and is increasing at a huge rate, we just aren't educating people in IT fast enough to keep up with demand. Serverless allows you to delegate a large portion of the complexity to a third party. If managed correctly this can reduce your development time dramatically. I'll go through some of the things that you need to take into account.

## Won't this cost me a fortune?
The advantage to any cloud system is that it scales with your application, which means if you configure it correctly and you investigate just how much the revenue you make relates to the load on your servers then you could save a huge amount of money over in-house hosted infrastructure.

Where serverless extends the benefits of this model is that you aren't paying for uptime of a server per month, you are paying for the load created by your application. If you don't use any resources it won't cost you any money (with a few exceptions).

## How do I know if it's right for my application?
I would strongly advise that you spend a good deal of time investigating the architecture you intend to build before you build it. If you are comfortable in another architecture then maybe this isn't right for you.

You also need to consider who is developing this application, do you have a lot of developers who will adapt well to a new way of thinking about how to develop applications?

Maybe a partial solution would be better for you, part on EC2 Virtual Machines, partially on serverless.

The serverless part of your application cannot be built the same way that you build every other app while still getting all the benefits.

## What do I get for going serverless?
I'll use this question to explain how to think about serverless, it's a different paradigm

### Configuration not code
Code takes time to maintain and it allows you to do complex things, things that are difficult to maintain. Configuration forces you to take a simple path and combine different configurations to make your application modular, scalable and easy to change.

#### Configuring with Cloud formation
Cloud formation is a way of defining your entire application in configuration files. Every message queue, API, authentication, authorisation, workflow, storage bucket, database schema and CDN is configured in YAML/JSON files and committed into your source control. You have the same application in every environment because it's in your source control. 

This is where the key value proposition for serverless becomes clear, want to kick off an event every time a file is created in s3, configure a notification to a message queue! What about a worker that subscribes to the queue? Configure a lambda function to subscribe to the SNS queue.

It also allows you to make your application incredibly secure, you can make sure every single part of your application never has access to anything it shouldn't do. Lambdas can be restricted to an S3 path, read but not list, create but not delete. Similarly, you can restrict access to DynamoDB and many other services.

Each component is configurable and nothing happens till you use it.

### Lambda Functions
Lambda Functions are functions that are run statelessly on demand or on a schedule, it's your code running in a container for a maximum time of 5 minutes. They require a bit of warm-up time which changes depending on your choice of language and they are also limited by how large the amount of code you upload. They often take about 1 second to warm up and double-digit milliseconds to pull data from dynamo once warmed.

You can schedule it to run every N minutes to avoid the container dying but make sure you need that before implementing it.

Do not try to use these for anything other than running code that is designed to do a single thing fast and could fail at any moment. You are also limited to 1000 concurrent executions until you explicitly request an increase in limit.

They are so configurable, you can subscribe to an update to DynamoDB, SNS, Cognito etc, there is no process waiting for a call, it's all configuration.

### DynamoDB
I have a love-hate relationship with this database. It's a NoSQL key-value store with a very limited feature set. It forces you to design for scale, for example, the primary key or hash key of your schema is automatically the shard key. You can't index across shard keys in a consistent way because they are likely stored on completely different servers. This is good because I have to design my application for the long-term up front. This is bad because I have to design my application for the long-term up front.

It also doesn't do transactions, you have to define it's read and write capacity, there are many hidden problems with concurrency and locking of data that won't occur to you till you are well into the weeds with this application. If you are considering using it I strongly advise you to spend time reading the documentation before doing so.

However it's also beautiful, I don't have to spend a lot of time planning my schemas, I don't have to think about clusters, fail-over, master, read-write and stored procedures. When I want a trigger on my data I create a dynamo stream which contains the full list of updates and I subscribe to that with a lambda function.

### Step Functions
Super simple workflow system, you define the flow in JSON/YAML, it keeps the state in JSON, you tell it which lambdas to call with what part of your state and you choose the part of your state that is altered by the result. You can build iterators, parallel execution, you can restructure your data using Pass states and make choices using the choice state. You'll pick it up really quick, the pain point is the lack of configurable subscriptions, I have yet to find a way to get it to subscribe to an SNS. I had to actually write code to kick this off #ServerlessWorldProblems

I mentioned earlier that lambdas could only run for a max 5 minutes and you shouldn't have long running functions, this fills that gap by allowing you to call lambdas to iterate through large loads. It also has fantastic logging which will allow you see exactly what the input/output was to each function at any given moment. Essential in your serverless application.

### SNS
It's simple, it's a notification service, you configure subscribers, it has at least once delivery. This is part of the glue that allows modular design, imagine a step function that calls a lambda to iterate through 100,000 records of data, on each page, it simply publishes the result to an SNS. Now your data processing lambda can run in parallel to process each page of that data as it gets added to the queue. It also has a retry/fallback story.

### Cloudfront
CDNs are amazing, use them. What if you were to ditch your server-side MVC and just put your static HTML/javascript in a CDN. You could put it all in S3 which costs a tiny amount of money, CloudFront would distribute it around the world so your response time would be tiny and you aren't coupling your server code to your frontend.

You need to call the server at some point, and that's where CloudFront multiple origins come in, you can put an API behind the CloudFront with different caching rules and hey presto, tightly controlled access to your backend

### Cognito
How many times have I built an authentication system, too many, that's how many. Cogito gives users, hierarchical groups and objects can have attributes. It works similar to a directory, it gives you session state, OAuth/SAML, multi-factor authentication, email/SMS confirmation. You can even map the details that your federated identity provider gives you to your own custom attributes. 

The best part is it integrates with IAM which is the authorisation story for everything in AWS, you'll get the current user and their permissions for free in every component of your application just because you didn't want to roll your own.

One gripe with this is it's region specific, I can't have one single URL for all OAuth things, I'd rather some sort of clever attribute based rule that would handle region mapping for me, but I'm likely going to have to roll my own on this one.

### Athena
You wouldn't think it to look at, but oh my dear lord is this amazing. You point this at any data in S3 and it will index it and read it like it's a database, I'm using it parse CSV right now and it's a god send. You can do complex SQL queries on data you read using a regex without spinning up a Hadoop cluster or something else heavily time-consuming. It's fast, it's [cheap](https://blog.skeddly.com/2016/12/looking-at-amazon-Athena-pricing.html) and you can save your query results for later reuse.

### Cloudwatch
If you don't have logging maintaining your app is going to be a nightmare, and if you are going serverless you get that for free. All of the services automatically create logs, step functions do, your lambdas do, everything will and you don't even have to write code.

Once you've generated some data from your app you'll be able to create dashboards and configure alarms so that you can see exactly what's going on. Be careful that you actually answer the important questions of your app with the dashboards, don't just create graphs for the sake of it. What do you need to know?

## Conclusion
I haven't covered all of AWS, and honestly, that would be foolish to do, this just gives you a quick overview of what's possible. If you enjoyed this post please let me know in the comments.