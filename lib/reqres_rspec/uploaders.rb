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
            URI(request.uri).host == 's3.amazonaws.com'
          end
        end
      end

      self.constants.each do |name|
        klass = Object.const_get("ReqresRspec::Uploaders::#{name}")
        if klass.public_instance_methods.include?(:upload)
          klass.upload
        end
      end
    end

  end
end
