require 'coderay'

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

        append_index
        append_panel
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
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/doc/rspec_doc_*.html"), secure: true)
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/doc/index.html"), secure: true)
        FileUtils.rm_rf(Dir.glob("#{Rails.root}/doc/panel.html"), secure: true)
      end

      # generates contents of HTML docs
      # TODO: more info
      def generate_header
        tpl_path = File.join(File.dirname(__FILE__), 'templates', 'header.erb')
        rendered_doc = ERB.new(File.open(tpl_path).read).result(binding)

        path = File.join(Rails.root, 'doc', 'rspec_doc_00000.html')
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

          path = File.join(Rails.root, 'doc', "rspec_doc_#{@index.to_s.rjust(5, '0') }.html")
          file = File.open(path, 'w')
          file.write(rendered_doc)
          file.close
          puts "Reqres::Writers::Html saved doc spec to #{path}"
        end
      end

      # creates an index file with iframes if does not exists
      def append_index
        index_file = File.join(Rails.root, 'doc', 'index.html')
        unless File.exists?(index_file)
          tpl_path = File.join(File.dirname(__FILE__), 'templates', 'index.erb')
          rendered_doc = ERB.new(File.open(tpl_path).read).result(binding)
          File.write index_file, rendered_doc
        end
      end

      def append_panel
        index_file = File.join(Rails.root, 'doc', 'panel.html')
        unless File.exists?(index_file)
          tpl_path = File.join(File.dirname(__FILE__), 'templates', 'panel.erb')
          rendered_doc = ERB.new(File.open(tpl_path).read).result(binding)
          File.write index_file, rendered_doc
        end
      end
    end
  end
end
