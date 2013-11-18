module ReqresRspec
  module Generators
    class Pdf
      # generates PDF file from existing HTML docs
      # TODO: more info
      def generate
        # http://www.princexml.com/download/
        pdf_tool_path = 'prince'
        html_docs_root = File.join(Rails.root, 'doc')
        pdf_doc_path = File.join(Rails.root, 'doc', "rspec_doc_#{Time.now.strftime("%d-%h-%Y_%H-%M")}.pdf")

        if `which #{pdf_tool_path}`.size > 0
          files = Dir["#{html_docs_root}/rspec_doc_*.html"]
          if files.size > 0
            files_arg = files.map { |f| f if f =~ /\/rspec_doc_\d+\.html/ }.compact.sort.join('" "')

            `#{pdf_tool_path} "#{files_arg}" -o "#{pdf_doc_path}"`

            puts "ReqresRspec::Generators::Pdf saved doc to #{pdf_doc_path}" if File.exists? pdf_doc_path
          else
            puts 'No HTML files found'
          end
        else
          puts "ERROR: #{pdf_tool_path} is not installed! Check README.md for more info"
        end
      end
    end
  end
end