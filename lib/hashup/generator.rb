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
      return if root?
      puts "setup #{mysite}..."
      directory("#{File.dirname(__FILE__)}/templates/", mysite, :exclude_pattern => /themes|contents/)
      %w[contents themes].each do |item|
        empty_directory(item)
        directory("#{File.dirname(__FILE__)}/templates/#{item}", "#{mysite}/#{item}", :verbose => false)
      end
    end

    desc "compile FILE", "compile a markdown file"
    def compile(file)
      fragment = Markascend.compile (File.open(file, "r").read)
      File.open("#{File.basename(file, ".ma")}.html", "w+") do |f|
        f.write(fragment)
      end
      puts "#{file} compiled"
    end

    desc "preview", "compile all files"
    def preview
      if root?
        empty_directory("output")
        site = Hashup::Site.new
        site.generate
        @configs = site.configs
        directory("#{File.dirname(__FILE__)}/templates/#{@configs["template_dir"]}/static", "#{@configs["output_dir"]}/static", :verbose => false)
        run_server
      else
        puts "not in the root"
      end
    end

    desc "post", "create a post"
    def post
      title = ask("the title of this post: ") 
      tags = ask("tags(seperated by comma or space): ").strip().split(/\s|,/).to_s.gsub(/"/,"")
      site = Hashup::Site.new
      @configs = site.configs
      create_file(File.join("#{@configs["content_dir"]}", "#{@configs["output_dir"]}", "#{title.gsub(/\s/, "_")}.ma")) do
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
      create_file(File.join("#{@configs["content_dir"]}", "#{@configs["pages_folder"]}", "#{name}.ma")) do
      <<META
---
title: #{name}
date: #{Time.new.to_s}
description: #{description} 
---
META
      end if name
    end

    desc "deploy", "deploy to github"
    def deploy
      site = Hashup::Site.new
      @configs = site.configs
      Dir.chdir "#{@configs["output_dir"]}" do
        system "git add . -f"
        puts "commiting site, updated at #{Time.now.utc}"
        message = "Site updated at #{Time.now.utc}"
        system "git commit -m \"#{message}\""
        system "git push origin master --force"
      end
    end

    desc "draft", "create a draft"
    def draft(doc)
    end

    private
    def root?
      File.exists? "config.yml"
    end

    def run_server
      `white_castle ./output`
    end
  end
end
