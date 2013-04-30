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
      @filename = filename
    end

    def configs
      YAML.load_file @filename
    end
  end
end
