module ReqresRspec
  module Formatters
    class JSON < Base
    private
      def write
        path = File.join(output_path, 'reqres_rspec.json')
        File.write(path, ::JSON.pretty_generate(records))
        logger.info "Reqres::Writers::#{self.class.name} saved doc spec to #{path}"
      end

      def cleanup_pattern
        'reqres_rspec.json'
      end
    end
  end
end
