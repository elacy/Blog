---
title: phpBB youtube BBCode
layout: post
categories:
  - Technology
tags:
  - PhpBB BBCode
---

![](/assets/images/2012/12/youtube-stacked_google_200px.png)

The standard response to how do I create a YouTube BBCode is <!-- more -->

Use the following BBCode usage:

`[youtube]http://www.youtube.com/watch?v={SIMPLETEXT}[/youtube]`

Then use the following HTML Replacement:

```
<object width=”425&#8243; height=”350&#8243;>
	<param name=”movie” value=”http://www.youtube.com/v/{SIMPLETEXT}”></param>
	<param name=”wmode” value=”transparent”></param>
	<embed src=”http://www.youtube.com/v/{SIMPLETEXT}” type=”application/x-shockwave-flash” wmode=”transparent” width=”425&#8243; height=”350&#8243;></embed>
</object>
```

Of course when you try this you will run into a problem. When your users attempt to try it with a YouTube url they copy pasted from YouTube they may be using https or there may be extra query parameters which will mean that the YouTube simply won't work.

A quick change will allow you to support that issue and as an added bonus all YouTube references will automatically use https

BBCode usage:

`[youtube]htt{IDENTIFIER}://www.youtube.com/watch?v={SIMPLETEXT}{TEXT}[/youtube]`

```
<object width="425" height="350">
	<param name="movie" value="https://www.youtube.com/v/{SIMPLETEXT}"></param>
	<param name="wmode" value="transparent"></param>
	<embed src="https://www.youtube.com/v/{SIMPLETEXT}" type="application/x-shockwave-flash" wmode="transparent" width="425" height="350"></embed>
</object>
```