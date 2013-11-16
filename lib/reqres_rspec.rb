# to enable mattr_accessor
require "active_support/core_ext/module/attribute_accessors"

require "reqres_rspec/version"
require "reqres_rspec/collector"

module ReqresRspec
  # Contains spec values read from rspec example, request and response
  mattr_accessor :records

  # define if all doc generation is enabled
  mattr_accessor :enabled
end

ReqresRspec.enabled = defined?(RSpec)

if !ReqresRspec.enabled
  puts "\nWARNING: ReqresRspec is disabled\n"
end

if ReqresRspec.enabled
  # initialize
  ReqresRspec.records = []

  RSpec.configure do |config|
    config.after(:each) do
      if defined?(request) && defined?(response)
        unless self.example.options.has_key?(:rspec_doc) && !self.example.options[:rspec_doc]
          ReqresRspec::Collector.collect(self, request, response)
        end
      end
    end

    config.after(:suite) do
      if ReqresRspec.records && ReqresRspec.records.size > 0
        puts 'TODO: save records'
        puts ReqresRspec.records.inspect
      end
    end
  end
end
