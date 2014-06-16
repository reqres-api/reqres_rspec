module ReqresRspec
  class Collector
    class ResponseDecorator
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

      delegate %i[status body headers], to: @response

      def initialize(response)
        @response = response
      end

      def to_h
        {
          code: status,
          body: body,
          headers: headers
        }
      end

      # read and cleanup response headers
      # returns Hash
      def headers
        headers.reject do |h|
          EXCLUDE_RESPONSE_HEADER_PATTERNS.any? { |p| h.starts_with? p }
        end
      end
    end
  end
end
