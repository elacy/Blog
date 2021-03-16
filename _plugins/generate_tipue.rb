# encoding: utf-8
#
# Jekyll tipuesearch_content generator.
# check http://www.tipue.com/search for more info
#
# Version: 0.1.1 
#
# Copyright (c) 2014 Nuno Furtado, http://about.me/nuno.furtado
# Licensed under the MIT license (http://www.opensource.org/licenses/mit-license.php)
#
# A generator that creates tipuesearch_content.js based on your current posts.
#
# To use it, simply drop this script into the _plugins directory of your Jekyll site.
#
# You also need to make sure your posts have a tipue_description element in the YAML, 
# this is used to show the text on the search page
#
# Your posts categories(categories element in the YAML) get loaded into tipue tags, 
# making them searchable.
#
# if you use a tags system (tags element in the YAML), tags are also loaded into 
# tipue tags, making them searchable
#
require 'rubygems'
require 'nokogiri'
require 'json'
require 'fileutils'
module Jekyll
	
	#This object represents page information we will be writing to tipuesearch_content.js
	class TipuePage 
			
			# Initializes a new TipuePage.
			#
			#  +title+ Page Title
			#  +tags+  Page Tags
			#  +loc+   Page url
			#  +text+  Page Description
			def initialize(site, page)
				@title = page.data['title']
				@tags =page.data['tags'].join(" ").concat(" ").concat(page.data['categories'].join(" "))
				@url = page.url
				
				renderer = Renderer.new(site, page)
				html = renderer.convert(page.content.to_s)
				@text= Nokogiri::HTML(html).text.gsub(/\{\%[^\%}]+%}/, "")
    		end
			
			def to_json
				hash = {}
				self.instance_variables.each do |var|
					hash[var.to_s.delete "@"] = self.instance_variable_get var
				end
				hash.to_json
			end
	
	
	end
	
	#This is our generator
	# it will recreate js/tipuesearch_content.js everytime jekyll build is run
	class TipueGenerator < Generator
		safe true
		
		def generate(site)
			@site = site

			page = PageWithoutAFile.new(@site, site.source, "/assets/js", "tipuesearch_content.js")
			pages = @site.posts.docs.map{ |post| TipuePage.new(@site, post).to_json }.join(",")

			page.content = "var tipuesearch = {\"pages\": [ #{pages} ]};"
			page.data["layout"] = nil

			@site.pages << page
		end
  end

end