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
            unless klass.public_instance_methods.include?(:process)
              raise "Formatter #{fmt} should respond to `process` method"
            end
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
  end
end
