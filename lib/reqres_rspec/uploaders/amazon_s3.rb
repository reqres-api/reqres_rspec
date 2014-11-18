require 'aws-sdk-core'
require 'mime/types'

module ReqresRspec
  module Uploaders
    class AmazonS3
      def initialize
        @path     = ReqresRspec.configuration.output_path
        @logger   = ReqresRspec.logger
        @enabled  = ReqresRspec.configuration.amazon_s3[:enabled] || false
        @bucket   = ReqresRspec.configuration.amazon_s3[:bucket]

        ::Aws.config = ReqresRspec.configuration.amazon_s3[:credentials]
        @s3 = ::Aws::S3::Client.new
      end
      attr_reader :logger, :path

      def self.upload
        uploader = self.new
        uploader.process if uploader.enabled?
      end

      def enabled?
        !!@enabled
      end

      def process
        prepare_bucket

        Dir["#{path}/**/*"].each { |file|
          next if File.directory?(file)
          local_path = file.gsub("#{@path}/", '')
          content_type = MIME::Types.type_for(local_path).first.content_type

          start = Time.now
          opts = {
            bucket: @bucket,
            key: local_path,
            body: File.open(file, 'rb'),
            acl: 'public-read',
            content_type: content_type
          }
          @s3.put_object opts
          done = Time.now

          puts "\n[#{local_path}] Uploaded in #{done.to_i - start.to_i}s"
        }
      end

    private
      def prepare_bucket
        @s3.create_bucket(
          acl: 'public-read',
          bucket: @bucket
        )

        @s3.put_bucket_website(
          bucket: @bucket,
          website_configuration:  {
            index_document: { suffix: 'index.html' }
          }
        )
      end
    end
  end
end
