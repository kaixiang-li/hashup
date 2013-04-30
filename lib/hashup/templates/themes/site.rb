require "slim"
require "tilt"
Slim::Engine.set_default_options pretty: true, sort_attrs: false


class Env
  attr_accessor :name, :author
end

env = Env.new
env.name = "test"

def render_file(filename)
  Tilt.new("_layout/#{filename}").render()
end

puts Tilt.new("_layout/_layout.slim").render(env) {
  File.open("../contents/_index/intro.html").read
}
