module ReqresRspec
  extend self

  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def logger
    @logger ||= if defined?(Rails)
      Rails.logger
    else
      Logger.new(STDOUT)
    end
  end

  def root
    configuration.root
  end

  class Configuration
    DEFAULT_FORMATTERS = %w(html pdf json)
    def initialize
      ReqresRspec.logger.level = Logger::INFO
      @root = if defined?(Rails)
        Rails.root.to_s
      else
        raise 'REQRES_RSPEC_ROOT is not defined' if ENV['REQRES_RSPEC_ROOT'].blank?
        ENV['REQRES_RSPEC_ROOT']
      end

      @templates_path = File.expand_path('../templates', __FILE__)
      @output_path = File.join(@root, '/doc/reqres')

      requested_formats = (ENV['REQRES_RSPEC_FORMATTERS'].to_s).split(',')
      requested_formats.sort_by!{|fmt| [DEFAULT_FORMATTERS.index(fmt), fmt]}
      @formatters = requested_formats.empty? ? %w(html) : requested_formats

      @title = 'API Docs'
    end

    attr_accessor :templates_path
    attr_accessor :output_path
    attr_accessor :title
    attr_accessor :formatters
    attr_reader :root
  end
end
