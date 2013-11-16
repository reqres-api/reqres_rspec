require 'reqres_rspec'

module ReqresRspec
  module Collector
    # collects spec data for further processing
    def Collector.collect(spec, request, response)
      record = {
        title: 'title',
      }

      ReqresRspec.records << record
    end
  end
end