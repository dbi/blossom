require 'ostruct'

module Blossom
  class Config
    class << self

      def method_missing(method_name, *args)
        @config ||= load_config
        @config.send method_name, *args
      end

      def load_config
        conf = OpenStruct.new
        conf.instance_eval File.read(config_path)
        conf
      end

      def app_path
        File.absolute_path(File.join(__FILE__, '..', '..'))
      end

      def config_path
        File.join(app_path, 'app', 'configuration.rb')
      end

    end
  end
end
