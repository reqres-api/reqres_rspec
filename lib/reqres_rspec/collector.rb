require 'collector/request_decorator'
require 'collector/action'

module ReqresRspec
  class Collector
    # Contains spec values read from rspec example, request and response
    attr_accessor :records

    # response headers contain many unnecessary information,
    # everything from this list will be stripped
    EXCLUDE_RESPONSE_HEADER_PATTERNS = %w[
      X-Frame-Options
      X-XSS-Protection
      X-Content-Type-Options
      X-UA-Compatible
    ]

    def initialize
      @records = []
    end

    # collects spec data for further processing
    def collect(spec, request, response)
      # TODO: remove boilerplate code
      return if request.nil? || response.nil? || !defined?(request.env)

      request = RequestDecorator.new(request)

      description = query_parameters = backend_parameters = 'not available'

      if request.env && request.params
        if request.params['controller'] && request.params['action']
          description = request.action.description
          backend_parameters, query_parameters = request.params.partition do |p|
            %w[controller action].include? p
          end
        end
      end

      ex_gr = spec.class.example.metadata[:example_group]
      section = ex_gr[:description]
      while !ex_gr.nil? do
        section = ex_gr[:description]
        ex_gr = ex_gr[:parent_example_group]
      end

      @records << {
        group: section, # Top level example group
        title: spec.class.example.full_description,
        description: spec.class.description,
        params: (request.action.params || []),
        request_path: request.symbolized_path,
        request: request.to_h,
        response: {
          code: response.status,
          body: response.body,
          headers: read_response_headers(response),
        }
      }
    end

    # sorts records alphabetically
    def sort
      self.records.sort!{ |x,y| x[:request_path] <=> y[:request_path] }
    end

    private

    # read and cleanup response headers
    # returns Hash
    def read_response_headers(response)
      headers = response.headers
      EXCLUDE_RESPONSE_HEADER_PATTERNS.each do |pattern|
        headers = headers.reject { |h| h if h.starts_with? pattern }
      end
      headers
    end
  end
end
