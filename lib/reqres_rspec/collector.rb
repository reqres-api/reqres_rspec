#require "active_support/core_ext/module/attribute_accessors"
#require 'reqres_rspec'

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
      record = {
        title: spec.example.full_description,
        description: get_action_description(request.env['action_dispatch.request.parameters']['controller'], request.env['action_dispatch.request.parameters']['action']),
        params: get_action_params(request.env['action_dispatch.request.parameters']['controller'], request.env['action_dispatch.request.parameters']['action']),
        request_path: get_symbolized_path(request),
        request: {
          host: request.host,
          url: request.url,
          path: request.path,
          method: request.request_method,
          query_parameters: request.env['action_dispatch.request.parameters'].reject { |p| %w[controller action].include? p },
          backend_parameters: request.env['action_dispatch.request.parameters'].reject { |p| !%w[controller action].include? p },
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

      self.records << record
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
          request_path = request_path.sub(value, ":#{key}") if request_path.index(value) >= 0
        end
      end

      request_path
    end

    # returns action comments taken from controller file
    # example TODO
    def get_action_comments(controller, action)
      lines = File.readlines(File.join(Rails.root, 'app', 'controllers', "#{controller}_controller.rb"))

      action_line = nil
      lines.each_with_index do |line, index|
        if line.match /\s*def #{action}/ #  def show
          action_line = index
          break
        end
      end

      if action_line
        comment_lines = []
        was_comment = true
        while action_line > 0 && was_comment
          action_line -= 1

          if lines[action_line].match /\s*#/
            comment_lines << lines[action_line].strip
          else
            was_comment = false
          end
        end

        comment_lines.reverse
      else
        'not found'
      end
    end

    # returns description action comments
    # example TODO
    def get_action_description(controller, action)
      comment_lines = get_action_comments(controller, action)

      description = []
      comment_lines.each_with_index do |line, index|
        if line.match /\s*#\s*@description/ # @description blah blah
          description << line.gsub(/\A\s*#\s*@description/, '').strip
          comment_lines[(index + 1)..-1].each do |multiline|
            if !multiline.match /\s*#\s*@params/
              description << multiline.gsub(/\A\s*#\s*/, '').strip
            else
              break
            end
          end
        end
      end

      description.join ' '
    end

    # returns params action comments
    # example TODO
    def get_action_params(controller, action)
      comment_lines = get_action_comments(controller, action)

      text_params = []
      last_new_param_index = nil
      comment_lines.each_with_index do |line, index|
        if line.match /\s*#\s*@params/ # @params id required Integer blah blah
          last_new_param_index = index
          text_params << line.gsub(/\A\s*#\s*@params/, '').strip
        elsif last_new_param_index && last_new_param_index == index - 1
          text_params.last << " #{line.gsub(/\A\s*#\s*/, '').strip}"
        end
      end

      params = []

      text_params.each do |param|
        match_data = param.match /(?<name>[a-z0-9A-Z_\[\]]+)?\s*(?<required>required)?\s*(?<type>Integer|Boolean|String|Text|Float|Date|DateTime|File)?\s*(?<description>.*)/

        if match_data
          params << {
            name: match_data[:name],
            required: match_data[:required],
            type: match_data[:type],
            description: match_data[:description],
          }
        else
          params << { description: param }
        end
      end

      params
    end
  end
end