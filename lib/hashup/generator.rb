require "thor"
module Hashup
  class Generator < ::Thor
    include Thor::Actions
    source_root File.dirname(__FILE__)
    desc "setup", "create your first site"
    def setup(mysite)
      puts "setup #{mysite}..."
      directory("templates/", mysite)
    end

    desc "post", "create a post"
    def post(doc)
    end

    desc "draft", "create a draft"
    def draft(doc)
    end
  end
end
