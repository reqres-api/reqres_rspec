require 'coderay'

module ReqresRspec
  module Formatters
    class HTML < Base
    private
      def write
        files = {
          'rspec_doc_table_of_content.html' => 'header.erb',
          'index.html' => 'index.erb',
          'panel.html' => 'panel.erb'
        }

        files.each { |filename, template| save(filename, render(template)) }

        @records.each do |record|
          @record = record
          save "rspec_doc_#{record[:filename]}.html", render('spec.erb')
        end
      end

      def cleanup_pattern
        '*.html'
      end

      def path(filename)
        File.join(ReqresRspec.configuration.templates_path, filename)
      end

      def render(filename, arguments = {})
        eval <<-RUBY
          #{ arguments.map {|k, v| "#{k} = #{v}"}.join("\n") }
          ERB.new(File.open(path(filename)).read).result(binding)
        RUBY
      end

      def save(filename, data)
        File.write(File.join(output_path, filename), data)
        logger.info "Reqres::Formatters::HTML saved #{path(filename)}"
      end
    end
  end
end
