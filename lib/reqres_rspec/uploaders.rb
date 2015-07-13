module ReqresRspec
  module Uploaders
    extend self

    def upload
      if defined?(WebMock)
        WebMock.allow_net_connect!
      end

      if defined?(VCR)
        VCR.configure do |c|
          c.ignore_request do |request|
            URI(request.uri).host == 's3.amazonaws.com' ||
              URI(request.uri).host.include?('google')
          end
        end
      end

      klass = Object.const_get("ReqresRspec::Uploaders::#{ENV['REQRES_UPLOAD']}")
      klass.upload if klass.respond_to?(:upload)
    end
  end
end
