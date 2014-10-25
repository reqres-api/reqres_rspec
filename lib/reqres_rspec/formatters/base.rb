module ReqresRspec
  module Formatters
    extend self

    def process(records)
      formatters = ReqresRspec.configuration.formatters
      raise 'No formatters defined' if formatters.empty?

      formatters.each do |fmt|
        case fmt
        when 'html'
          HTML.new(records).process
        when 'pdf'
          HTML.new(records).process unless formatters.include?('html')
          Pdf.new(records).process
        when 'json'
          JSON.new(records).process
        else
          begin
            klass = Object.const_get(fmt)
            raise "Formatter #{fmt} should respond to `process` method" if klass.respond_to?(:process)
            klass.new(records).process
          rescue NameError => e
            if e.message =~ /(uninitialized constant|wrong constant name) #{fmt}$/
              raise "Formatter #{fmt} does not exists"
            else
              raise e
            end
          end
        end
      end
    end


    class Base
      def initialize(records)
        @records = records
        @output_path = ReqresRspec.configuration.output_path
        @logger = ReqresRspec.logger
      end
      attr_reader :logger, :output_path, :records

      def process
        cleanup
        write
      end
    private
      def write
        raise 'Not Implemented'
      end

      def cleanup_pattern
        '**/*'
      end

      def cleanup
        unless Dir.exist?(output_path)
          Dir.mkdir(output_path)
          logger.info "#{output_path} was recreated"
        end
        FileUtils.rm_rf(Dir.glob("#{output_path}/#{cleanup_pattern}"), secure: true)
      end
    end
  end
end
