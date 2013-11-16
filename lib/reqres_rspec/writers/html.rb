module ReqresRspec
  module Writers
    class Html
      def initialize(records)
        @records = records
      end

      def write
        recreate_doc_dir
        cleanup
        generate_header
        generate_specs
      end

      private

      # recreates /doc dir if it does not exist
      def recreate_doc_dir
        doc_dir = File.join(Rails.root, 'doc')
        unless Dir.exist?(doc_dir)
          Dir.mkdir(doc_dir)
          puts "#{doc_dir} was recreated"
        end
      end

      # deletes previous version of HTML docs
      # TODO: more info
      def cleanup
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/docs/rspec_docs_*.html"), secure: true)
      end

      # generates contents of HTML docs
      # TODO: more info
      def generate_header
        tpl_path = File.join(File.dirname(__FILE__), 'templates', 'header.erb')
        rendered_doc = ERB.new(File.open(tpl_path).read).result(binding)

        path = File.join(Rails.root, 'docs', 'rspec_docs_00000.html')
        file = File.open(path, 'w')
        file.write(rendered_doc)
        file.close
        puts "Reqres::Writers::Html saved doc header to #{path}"
      end

      # generates each separate spec example doc
      # TODO: more info
      def generate_specs
        tpl_path = File.join(File.dirname(__FILE__), 'templates', 'spec.erb')

        @records.each_with_index do |record, index|
          @record = record
          @index = index + 1

          rendered_doc = ERB.new(File.open(tpl_path).read).result(binding)

          path = File.join(Rails.root, 'docs', "rspec_docs_#{('0000' + (@index).to_s)[-5, 5]}.html")
          file = File.open(path, 'w')
          file.write(rendered_doc)
          file.close
          puts "Reqres::Writers::Html saved doc spec to #{path}"
        end
      end
    end
  end
end