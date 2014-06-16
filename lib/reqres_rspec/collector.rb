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

    # request headers contain many unnecessary information,
    # everything that match items from this list will be stripped
    EXCLUDE_REQUEST_HEADER_PATTERNS = %w[
      rack.
      action_dispatch
      REQUEST_METHOD
      SERVER_NAME
      SERVER_PORT
      QUERY_STRING
      SCRIPT_NAME
      CONTENT_LENGTH
      HTTPS
      HTTP_HOST
      HTTP_USER_AGENT
      REMOTE_ADDR
      PATH_INFO
    ]

    def initialize
      self.records = []
    end

    # collects spec data for further processing
    def collect(spec, request, response)
      # TODO: remove boilerplate code
      return if request.nil? || response.nil? || !defined?(request.env)

      description = query_parameters = backend_parameters = 'not available'
      params = []
      if request.env && (request_params = request.env['action_dispatch.request.parameters'])
        if request_params['controller'] && request_params['action']
          action = Action.new(request_params['controller'], request_params['action'])

          description = action.description
          params = action.params
          query_parameters = request_params.reject { |p| %w[controller action].include? p }
          backend_parameters = request_params.reject { |p| !%w[controller action].include? p }
        end
      end

      ex_gr = spec.class.example.metadata[:example_group]
      section = ex_gr[:description]
      while !ex_gr.nil? do
        section = ex_gr[:description]
        ex_gr = ex_gr[:parent_example_group]
      end

      self.records << {
        group: section, # Top level example group
        title: spec.class.example.full_description,
        description: spec.class.description,
        params: params,
        request_path: get_symbolized_path(request),
        request: {
          host: request.host,
          url: request.url,
          path: request.path,
          method: request.request_method,
          query_parameters: query_parameters,
          backend_parameters: backend_parameters,
          body: request.body.read,
          content_length: request.content_length,
          content_type: request.content_type,
          headers: read_request_headers(request),
          accept: request.accept,
        },
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

    # read and cleanup request headers
    # returns Hash
    def read_request_headers(request)
      headers = {}
      request.env.keys.each do |key|
        headers.merge!(key => request.env[key]) if EXCLUDE_REQUEST_HEADER_PATTERNS.all? { |p| !key.starts_with? p }
      end
      headers
    end

    # replace each first occurrence of param's value in the request path
    #
    # example
    #   request path = /api/users/123
    #   id = 123
    #   symbolized path => /api/users/:id
    #
    def get_symbolized_path(request)
      request_path = request.path

      request.env['action_dispatch.request.parameters'].
        reject { |param| %w[controller action].include? param }.
        each do |key, value|
        if value.is_a? String
          index = request_path.index(value)
          if index && index >= 0
            request_path = request_path.sub(value, ":#{key}")
          end
        end
      end

      request_path
    end
  end
end
