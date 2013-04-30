require "slim"
require "yaml"
require "ostruct"
require "markascend"
require_relative "configuration"

module Hashup
  class Site    
    def initialize
      Slim::Engine.set_default_options pretty: true, sort_attrs: false
      @configs = self.load_config
      @infos = self.load_infos
    end

    def generate
      
      # generate posts
      get_posts.each do |post|
        generated_post = Tilt.new("themes/_layout/_layout.slim").render(OpenStruct.new(@infos)) {
          ::Markascend.compile File.open(post).read
        }
        puts "#{post} generated.."
        File.open("output/#{File.basename(post, ".mad")}.html", 'w+') do |f|
          f.puts generated_post
        end
      end

      # generate index.html
      File.open("output/index.html", 'w+') do |f|
        index = Tilt.new("themes/_layout/_layout.slim").render(OpenStruct.new(@infos)) {
          list = self.get_generated_posts_list
          @infos["list"] = self.get_generated_posts_list
          Slim::Template.new("themes/index.slim").render(OpenStruct.new(@infos))
        }
        f.puts index
        puts "index.html generated"
      end
    end

    def get_posts
      Dir.glob "**/*.{mad, md, markdown}"
    end

    def get_generated_posts_list
      posts_list = []
      get_posts.map do |post|
        posts_list << "#{File.basename(post, ".mad")}.html"
      end
      posts_list
    end

    def load_infos
      infos = {}
      Dir.glob("**/*.{yml, yaml}").map do |info|
        next unless info =~ Regexp.new(@configs["content_dir"])
        infos.merge! (YAML.load_file info)
      end
      infos
    end

    def load_config
      configrable = Hashup::Configuration.new "config.yml"
      configrable.configs 
    end
  end
end

def render_file(filename)
  ss = Hashup::Site.new
  infos = OpenStruct.new(ss.load_infos)
  Slim::Template.new("themes/_layout/#{filename}").render(infos)
end
