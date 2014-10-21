require 'coderay'

module ReqresRspec
  module Writers
    class JSONFormatter
      def initialize(records)
        @records = records
      end

      def write
        recreate_doc_dir
        cleanup

        path = File.join(ENV['REQRES_RSPEC_ROOT'], 'doc', 'reqres_rspec.json')
        File.write(path, JSON.pretty_generate(@records))
        puts "Reqres::Writers::JSONFormatter saved doc spec to #{path}"
      end

      private

      # recreates /doc dir if it does not exist
      def recreate_doc_dir
        doc_dir = File.join(ENV['REQRES_RSPEC_ROOT'], 'doc')
        unless Dir.exist?(doc_dir)
          Dir.mkdir(doc_dir)
          puts "#{doc_dir} was recreated"
        end
      end

      # deletes previous version of HTML docs
      # TODO: more info
      def cleanup
        FileUtils.rm_rf(Dir.glob("#{ENV['REQRES_RSPEC_ROOT']}/doc/reqres_rspec.json"), secure: true)
      end
    end
  end
end
