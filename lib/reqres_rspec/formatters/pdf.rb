module ReqresRspec
  module Formatters
    class Pdf < Base
      # generates PDF file from existing HTML docs
      # TODO: more info
      def write
        # http://www.princexml.com/download/
        pdf_tool_path = 'prince'
        pdf_doc_path = File.join(output_path, 'reqres_rspec.pdf')

        if `which #{pdf_tool_path}`.size > 0
          files = Dir["#{output_path}/*.html"]
          files.reject!{ |filename| filename.scan(/rspec_doc/).empty? }
          files.delete("#{output_path}/rspec_doc_table_of_content.html")
          files.unshift("#{output_path}/rspec_doc_table_of_content.html")

          if files.size > 0
            files_arg = files.join('" "')
            `#{pdf_tool_path} "#{files_arg}" -o "#{pdf_doc_path}"`

            logger.info "ReqresRspec::Formatters::Pdf saved doc to #{pdf_doc_path}" if File.exists? pdf_doc_path
          else
            logger.error 'No HTML files found'
          end
        else
          logger.error "#{pdf_tool_path} is not installed! Check README.md for more info"
        end
      end

      def cleanup_pattern
        'reqres_rspec.pdf'
      end
    end
  end
end
