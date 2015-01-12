require 'reqres_rspec/version'
require 'reqres_rspec/utils'
require 'reqres_rspec/configuration'
require 'reqres_rspec/collector'
require 'reqres_rspec/formatters'
require 'reqres_rspec/formatters/base'
require 'reqres_rspec/formatters/html'
require 'reqres_rspec/formatters/json'
require 'reqres_rspec/formatters/pdf'
require 'reqres_rspec/uploaders'
require 'reqres_rspec/uploaders/amazon_s3'

if defined?(RSpec) && ENV['REQRES_RSPEC'] == '1'
  collector = ReqresRspec::Collector.new

  RSpec.configure do |config|
    config.after(:each) do |example|
      meta_data = self.class.example.metadata
      if meta_data[:type] == :request && process_example?(meta_data, example)
        begin
          if defined?(Rails)
            collector.collect(self, example, self.request, self.response)
          elsif defined?(Sinatra)
            collector.collect(self, example, self.last_request, self.last_response)
          end
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
        ReqresRspec::Uploaders.upload if ENV['REQRES_UPLOAD'] == '1'
      end
    end
  end

  def process_example?(meta_data, example)
    !(meta_data[:skip_reqres] || example.metadata[:skip_reqres])
  end
end
