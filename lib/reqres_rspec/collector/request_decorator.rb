module ReqresRspec
  class Collector
    class RequestDecorator
      attr_reader :action

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

      def initialize(request)
        @request = request
        @action = Action.new(request_params['controller'], request_params['action'])
      end

      delegate %i[env host url path request_method body content_length content_type accept], to: :@request

      def to_h
        {
          host: host,
          url: url,
          path: path,
          method: request_method,
          query_parameters: query_parameters,
          backend_parameters: backend_parameters,
          body: body.read,
          content_length: content_length,
          content_type: content_type,
          headers: read_request_headers(request),
          accept: accept
        }
      end

      def params
        env['action_dispatch.request.parameters']
      end

      # read and cleanup request headers
      # returns Hash
      def headers
        headers = {}
        @request.env.keys.each do |key|
          headers.merge!(key => @request.env[key]) if EXCLUDE_REQUEST_HEADER_PATTERNS.all? { |p| !key.starts_with? p }
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
      def symbolized_path
        request_path = request.path

        @request.env['action_dispatch.request.parameters'].
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
end
