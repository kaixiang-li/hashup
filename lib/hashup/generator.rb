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
      directory("templates/", mysite)
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
      site = Hashup::Site.new
      site.generate
      directory("templates/themes/static/", "templates/output/")
      `white_castle templates/output/`
    end

    desc "post", "create a post"
    def post(doc)

    end

    desc "draft", "create a draft"
    def draft(doc)
    end
  end
end
