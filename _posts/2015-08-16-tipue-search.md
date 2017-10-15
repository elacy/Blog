---
title: Tipue, the JavaScript Search
layout: post
categories:
  - Technology
tags:
  - Javascript
  - jQuery
  - Search
  - Pretzel
---
[Tipue](http://www.tipue.com/search/) is a browser based JavaScript site search that allows you to add search to your site without adding any server side code.

What you would normally do with a third party search provider like [Google Custom Search Engine](https://cse.google.ie/cse/) or server side search software like [Solr](http://lucene.apache.org/solr/) you do with a small JavaScript file.<!-- more -->

There are two major downsides: Tipue wants to get you up and running fast, so the HTML generation is built-in, if you aren't happy with the HTML it generates this might mean editing the JavaScript, and because it's a relatively small JavaScript file it doesn't carry the same querying and indexing functionality you'd expect from a dedicated search solution.

#### Querying

- Entering a sentence without any special characters searches for documents that contain every word entered 
- **Exact Search**: You can specify an exact phrase using quotes, for example "Fender Bender"
- **Exclude**: You can exclude a word using a minus sign, for example -Fender

#### Indexing

Tipue can build/retrieve its index in three ways:

- **Static** means that you provide Tipue with the index which is a JSON file
- **JSON** is the same as Static only you provide Tipue with a URL to the JSON file
- **Live** means that you provide Tipue with a list of URLs for it to index

#### HTML Generation

The HTML generated isn't semantic, it's mostly divs with classes, below is an example search item:

```html
<div class="tipue_search_content_title">
	<a href="http://www.tipue.com/search">Tipue Search, a site search engine jQuery plugin</a>
</div>
<div class="tipue_search_content_url">
	<a href="http://www.tipue.com/search">www.tipue.com/search</a>
</div>
<div class="tipue_search_content_text">
	<span class="h01">Tipue</span> Search is a site search engine jQuery plugin. It's free, open source, responsive and fast. Tipue Search only needs a browser that supports ...
</div>
```

Most of the rest of the outputted HTML is similar, aside from the paging which uses an unordered list.

I'd really like them to have a function that allows you to query using their search capability and generate your own HTML, or at the very least offer some sort of HTML templating.

#### Performance

This is going to be an issue if your site is large, however for my little blog it's lightning fast, try it yourself.

#### Generating the index with Pretzel

I use Pretzel to generate my blog and so it made sense for me to do write a Pretzel plugin to generate the Tipue Index. You can find that plugin [here](https://github.com/elacy/Pretzel.Tipue "Pretzel.Tipue").

---

Try the search out and let me know what you think in the comments below. 

