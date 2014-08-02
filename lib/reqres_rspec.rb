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
      meta_data = self.class.example.metadata
      if meta_data[:type] == :request && !meta_data[:skip_reqres] == true
        begin
          collector.collect(self, self.request, self.response)
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
