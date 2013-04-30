require "slim"
require "json"
require "markascend"

module Hashup
  class Env
    attr_accessor :list
  end
  class Site    
    def initialize
      Slim::Engine.set_default_options pretty: true, sort_attrs: false
      @base_url = "templates"

    end

    def generate
      # generate posts
      get_posts.each do |post|
        generated_post = Tilt.new("#{@base_url}/themes/_layout/_layout.slim").render() {
          ::Markascend.compile File.open(post).read
        }
        puts "#{post} generated.."
        File.open("#{@base_url}/output/#{File.basename(post, ".mad")}.html", 'w+') do |f|
          f.puts generated_post
        end
      end

      # generate index.html
      File.open("#{@base_url}/output/index.html", 'w+') do |f|
        index = Tilt.new("#{@base_url}/themes/_layout/_layout.slim").render() {
          list = self.get_generated_posts_list
          env = Env.new
          env.list = self.get_generated_posts_list
          Tilt.new("#{@base_url}/themes/index.slim").render(env)
        }
        f.puts index
        puts "index.html generated"
      end
    end

    def get_posts
      Dir.glob "**/*.{mad, md, markdown}"
    end

    def get_generated_posts_list
      posts_list = {list:  []}
      get_posts.map do |post|
        posts_list[:list] << "#{File.basename(post, ".mad")}.html"
      end
      posts_list
    end
  end
end

def render_file(filename)  
  Tilt.new("templates/themes/_layout/#{filename}").render()
end

ss = Hashup::Site.new
ss.generate
