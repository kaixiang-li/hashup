require "yaml"
module  Hashup
  class Configuration
    DEFAULTS = {
      'template_dir' => "themes",
      'content_dir' => "contents",
      'output_dir' => "output",
      'server' => {
        'port' => 9817
      }
    }

    def initialize filename
      if File.exists? filename
        @filename = filename
      else
        puts "#{filename} not found, maybe you are not in the right folder"
      end
    end

    def configs
      return YAML.load_file @filename if @filename
      DEFAULTS
    end
  end
end
