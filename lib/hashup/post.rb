require "yaml"
require "markascend"
module Hashup
  class Post
    attr_accessor :filename, :title, :date, :tags, :metadata, :contents
    def initialize post
      self.parse_post post
      @filename = "#{File.basename(post,".mad")}.html"
      @title = @metadata["title"]
      @date = @metadata["date"]
      @tags = @metadata["tags"]
    end

    def parse_post post
      contents= File.open(post).read
      if(md = contents.match(/^(?<metadata>---\s*\n.*?\n?)^(---\s*$\n?)/m))
        @contents = ::Markascend.compile md.post_match, toc: true
        @metadata = YAML.load(md[:metadata]) 
      end
    end
  end
end
