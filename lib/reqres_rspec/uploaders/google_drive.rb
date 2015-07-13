require 'google/api_client'
require 'google_drive'

module ReqresRspec
  module Uploader
    # You can find more detailed information here https://github.com/gimite/google-drive-ruby
    class GoogleDrive
      def initialize
        @path     = ReqresRspec.configuration.output_path
        @logger   = ReqresRspec.logger

        client = Google::APIClient.new
        auth = client.authorization
        auth.client_id = ENV['GOOGLE_CLIENT_ID']
        auth.client_secret = ENV['GOOGLE_CLIENT_SECRET']
        auth.scope = [
            'https://www.googleapis.com/auth/drive',
            'https://spreadsheets.google.com/feeds/'
        ]
        auth.redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'
        puts("\n\n1. Open this page:\n%s\n\n" % auth.authorization_uri)
        puts('2. Enter the authorization code shown in the page: ')
        auth.code = $stdin.gets.chomp
        auth.fetch_access_token!
        access_token = auth.access_token
        @session = GoogleDrive::GoogleDrive.login_with_oauth(access_token)
      end

      attr_reader :logger, :path

      def self.upload
        uploader = self.new
        uploader.process
      end

      def process
        Dir["#{path}/**/*"].each { |file|
          next if File.directory?(file)
          local_path = file.gsub("#{@path}/", '')

          start = Time.now
          @session.upload_from_file(file, local_path, convert: false)
          done = Time.now

          puts "\n[#{local_path}] Uploaded in #{done.to_i - start.to_i}s"
        }
      end
    end
  end
end
