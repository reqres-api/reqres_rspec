require 'reqres_rspec/version'
require 'reqres_rspec/collector'
require 'reqres_rspec/writers/html'
require 'reqres_rspec/generators/pdf'

if defined?(RSpec) && ENV['REQRES_RSPEC'] == '1'
  collector = ReqresRspec::Collector.new

  RSpec.configure do |config|
    config.after(:each) do
      if defined?(request) && defined?(response)
        unless self.example.options.has_key?(:rspec_doc) && !self.example.options[:rspec_doc]
          collector.collect(self, request, response)
        end
      end
    end

    config.after(:suite) do
      if collector.records.size > 0
        ReqresRspec::Writers::Html.new(collector.records).write
        ReqresRspec::Generators::Pdf.new.generate
      end
    end
  end
else
  puts "\nNOTICE: ReqresRspec is disabled. run RSpec with REQRES_RSPEC=1 environment var\n"
end
