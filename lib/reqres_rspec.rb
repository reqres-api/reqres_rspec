require 'reqres_rspec/version'
require 'reqres_rspec/configuration'
require 'reqres_rspec/collector'
require 'reqres_rspec/formatters/base'
require 'reqres_rspec/formatters/html'
require 'reqres_rspec/formatters/json'
require 'reqres_rspec/formatters/pdf'

if defined?(RSpec) && ENV['REQRES_RSPEC'] == '1'
  collector = ReqresRspec::Collector.new

  RSpec.configure do |config|
    config.after(:each) do
      if defined?(Rails)
        meta_data = self.class.example.metadata
        if meta_data[:type] == :request && !meta_data[:skip_reqres] == true
          begin
            collector.collect(self, self.request, self.response)
          rescue NameError
            raise $!
          end
        end
      elsif defined?(Sinatra)
        begin
          collector.collect(self, self.last_request, self.last_response)
        rescue Rack::Test::Error
          #
        rescue NameError
          raise $!
        end
      end
    end

    config.after(:suite) do
      if collector.records.size > 0
        collector.sort
        ReqresRspec::Formatters.process(collector.records)
      end
    end
  end
end
