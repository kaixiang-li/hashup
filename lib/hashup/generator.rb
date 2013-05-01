#!/usr/bin/env ruby
require "thor"
module Hashup
  class Generator < ::Thor
    include Thor::Actions

    def self.source_root
      File.dirname(__FILE__)
    end

    desc "setup", "create your first site"
    def setup(mysite)
      puts "setup #{mysite}..."
      directory("#{File.dirname(__FILE__)}/templates/", mysite)
    end

    desc "compile FILE", "compile a markdown file"
    def compile(file)
      fragment = Markascend.compile (File.open(file, "r").read)
      File.open("#{File.basename(file, ".mad")}.html", "w+") do |f|
        f.write(fragment)
      end
      puts "#{file} compiled"
    end

    desc "preview", "compile all files"
    def preview
      empty_directory("output")
      site = Hashup::Site.new
      site.generate
      directory("#{File.dirname(__FILE__)}/templates/themes/static", "output/static")
      `white_castle output/`
    end

    desc "post", "create a post"
    def post
      title = ask("the title of this post: ") 
      tags = ask("tags(seperated by comma or space): ").strip().split(/\s|,/).to_s.gsub(/"/,"")
      create_file(File.join("contents", "_posts", "#{title.gsub(/\s/, "_")}.mad")) do
        <<META
---
title: #{title}
tags: #{tags}
date: #{Time.new.to_s}
---
META
      end if title
    end

    desc "page", "create a page"
    def page
      name = ask("the name of the page: ")
      description = ask("description: ").chomp!
      create_file(File.join("contents", "_pages", "#{name}.mad")) do
      <<META
---
title: #{name}
date: #{Time.new.to_s}
description: #{description} 
---
META
      end if name
    end

    desc "draft", "create a draft"
    def draft(doc)
    end
  end
end
