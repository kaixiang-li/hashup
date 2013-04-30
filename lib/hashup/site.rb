require "slim"
module Hashup
  class Site    
    def initialize
      Slim::Engine.set_default_options pretty: true, sort_attrs: false
    end

    def generate
      puts Tilt.new("templates/themes/_layout/_layout.slim").render() {
        File.open("templates/contents/_index/intro.html").read
      }
    end

    
  end
end

def render_file(filename)  
  Tilt.new("templates/themes/_layout/#{filename}").render()
end


