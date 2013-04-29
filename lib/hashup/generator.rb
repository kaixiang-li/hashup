module Hashup
  class Generator < Thor
    desc "setup", "create your first site"
    def setup(mysite)
      puts "setup, #{mysite}"
    end

    desc "post", "create a post"
    def post(doc)
    end

    desc "draft", "create a draft"
    def draft(doc)
    end
  end
end
