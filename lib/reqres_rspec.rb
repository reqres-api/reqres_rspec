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
      unless self.example.options.has_key?(:collect_for_doc) && !self.example.options[:collect_for_doc]
        if defined?(self.request) && defined?(self.response)
          collector.collect(self, self.request, self.response)
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
else
  puts "\nNOTICE: ReqresRspec is disabled. run `REQRES_RSPEC=1 bundle exec rspec`\n"
end
