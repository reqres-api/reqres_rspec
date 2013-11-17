module ReqresRspec
  module Generators
    class Pdf
      # generates PDF file from existing HTML docs
      # TODO: more info
      def generate
        wkhtmltopdf_path = '/Applications/wkhtmltopdf.app/Contents/MacOS/wkhtmltopdf'
        html_docs_root = File.join(Rails.root, 'doc')
        pdf_doc_path = File.join(Rails.root, 'doc', "spec_#{Time.now.strftime("%d-%h-%Y_%H-%M")}.pdf")

        if File.exists?(wkhtmltopdf_path)
          files = Dir["#{html_docs_root}/rspec_docs_*.html"]
          if files.size > 0
            files_arg = files.map { |f| f if f =~ /\/rspec_docs_\d+\.html/ }.compact.sort.join('" "')

            `#{wkhtmltopdf_path} "#{files_arg}" "#{pdf_doc_path}"`

            puts "saved to #{pdf_doc_path}" if File.exists? pdf_doc_path
          else
            puts 'No HTML files found'
          end
        else
          puts 'ERROR: wkhtmltopdf app not installed! Please check http://code.google.com/p/wkhtmltopdf/ for more info'
        end
      end
    end
  end
end