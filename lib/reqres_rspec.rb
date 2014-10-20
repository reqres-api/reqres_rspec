require 'reqres_rspec/version'
require 'reqres_rspec/collector'
require 'reqres_rspec/writers/html'
require 'reqres_rspec/writers/json_formatter'
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
        if meta_data[:type] == :request && !meta_data[:skip_reqres] == true
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
        formatters = %w(html pdf json)

        requested_formats = (ENV['REQRES_RSPEC_FORMATTERS'] || 'html').split(',')
        requested_formats.sort_by!{|fmt| [formatters.index(fmt), fmt]}
        requested_formats.each do |fmt|
          case fmt
          when 'html'
            ReqresRspec::Writers::Html.new(collector.records).write
          when 'pdf'
            ReqresRspec::Writers::Html.new(collector.records).write unless requested_formats.include?('html')
            ReqresRspec::Generators::Pdf.new.generate
          when 'json'
            ReqresRspec::Writers::JSONFormatter.new(collector.records).write
          else
            puts "No formatters defined, define one of #{formatters} in REQRES_RSPEC_FORMATTERS"
          end
        end

        #
      end
    end
  end
end
