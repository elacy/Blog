# Lacy.ie
This is my blog in all it's overengineered glory, heavily and hastily modified to suit my needs.

I'm keeping it public in case anyone might benefit from it, but it comes with a health warning, I've removed some of the customisations from it that were in Kasper just so I don't have to spend too much time on it.

Check out the finished product at [lacy.ie](https://www.lacy.ie)

This is all based on the kasper theme so take a look at their [readme](https://github.com/rosario/kasper/blob/master/README.md) for the details: 

## Installation

    git clone https://github.com/elacy/Blog.git
    cd Blog
    gem install bundle
    bundle install

## What's bundle?
It installs all the ruby gems which are libraries I use to generate the amazingness that is my blog!

## How did you get search working on a statically generated site?
I wrote a blog post on that, check it out [here](https://www.lacy.ie/technology/2015/08/16/tipue-search.html)

## What do you use for hosting
I'm using aws for my hosting, here is how to set that up [alexbilbie.com/...jekyll-website/](https://alexbilbie.com/2016/12/codebuild-codepipeline-update-jekyll-website/)

### Why would I want to do that
It's free for a year and when it's not free it's pretty cheap for a highly available, low latency, scalable solution, I'll be honest you would probably be better off with wordpress, as would I but it's fun to set up.

### Did you do anything different to the above guide
Yes, I added the delete ability to s3 objects and I put a cloudfront in front of my S3 rather than exposing the S3 directly. I mostly wanted to do that to play with Cloudfront, caching this kind of content is kind of a nobrainer if you have the time to spend on it.

If you want to copy me then take a look at my buildspec.yml and add the permission to delete objects to the cloudbuild role.

## What's next in the evolution of this blog?
I want to spend more time writing things I've learnt than tinkering but here is my list
- Script to generate new post based on title with correct date etc
- 404 should automatically search my content to find posts
- Related content should be displayed below each post
- About me page with links to linked in, github (help out the stalkers)
- Make sure it's not syncing content that hasn't changed to s3