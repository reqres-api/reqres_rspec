require 'reqres_rspec/version'
require 'reqres_rspec/collector'
require 'reqres_rspec/writers/html'
require 'reqres_rspec/generators/pdf'

if defined?(RSpec) && ENV['REQRES_RSPEC'] == '1'
  collector = ReqresRspec::Collector.new

  RSpec.configure do |config|
    config.after(:each) do
      # TODO: remove boilerplate code
      # TODO: better options

      if defined?(Rails)
        ENV['REQRES_RSPEC_ROOT'] = Rails.root.to_s
        ENV['REQRES_RSPEC_APP'] = Rails.application.class.to_s.sub('::Application', '')

        meta_data = self.class.example.metadata
        if meta_data[:type] == :request && meta_data[:skip_reqres] == true
          begin
            collector.collect(self, self.request, self.response)
          rescue NameError
            raise $!
          end
        end
      elsif defined?(Sinatra)
        raise 'REQRES_RSPEC_ROOT is not defined' if ENV['REQRES_RSPEC_ROOT'].blank?
        raise 'REQRES_RSPEC_APP is not defined' if ENV['REQRES_RSPEC_APP'].blank?

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
        ReqresRspec::Writers::Html.new(collector.records).write
        ReqresRspec::Generators::Pdf.new.generate
      end
    end
  end
end
