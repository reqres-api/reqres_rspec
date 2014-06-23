module ReqresRspec
  class Collector
    class Action
      def initialize(controller, action)
        @controller = controller
        @action = action
      end

      # returns action comments taken from controller file
      # example TODO
      def comments
        lines = File.readlines(File.join(Rails.root, 'app', 'controllers', "#{@controller}_controller.rb"))

        action_line = nil
        lines.each_with_index do |line, index|
          if line.match /\s*def #{@action}/ #  def show
            action_line = index
            break
          end
        end

        if action_line
          comment_lines = []
          was_comment = true
          while action_line > 0 && was_comment
            action_line -= 1

            if lines[action_line].match /\s*#/
              comment_lines << lines[action_line].strip
            else
              was_comment = false
            end
          end

          comment_lines.reverse
        else
          ['not found']
        end
      rescue Errno::ENOENT
        ['not found']
      end

      # returns description action comments
      # example TODO
      def description
        comment_lines = action_comments(@controller, @action)

        description = []
        comment_lines.each_with_index do |line, index|
          if line.match /\s*#\s*@description/ # @description blah blah
            description << line.gsub(/\A\s*#\s*@description/, '').strip
            comment_lines[(index + 1)..-1].each do |multiline|
              if !multiline.match /\s*#\s*@params/
                description << multiline.gsub(/\A\s*#\s*/, '').strip
              else
                break
              end
            end
          end
        end

        description.join ' '
      end

      # returns params action comments
      # example TODO
      def params
        comment_lines = action_comments(@controller, @action)

        text_params = []
        last_new_param_index = nil
        comment_lines.each_with_index do |line, index|
          if line.match /\s*#\s*@params/ # @params id required Integer blah blah
            last_new_param_index = index
            text_params << line.gsub(/\A\s*#\s*@params/, '').strip
          elsif last_new_param_index && last_new_param_index == index - 1
            text_params.last << " #{line.gsub(/\A\s*#\s*/, '').strip}"
          end
        end

        params = []

        text_params.each do |param|
          match_data = param.match /(?<name>[a-z0-9A-Z_\[\]]+)?\s*(?<required>required)?\s*(?<type>Integer|Boolean|String|Text|Float|Date|DateTime|File)?\s*(?<description>.*)/

          if match_data
            params << {
              name: match_data[:name],
              required: match_data[:required],
              type: match_data[:type],
              description: match_data[:description],
            }
          else
            params << { description: param }
          end
        end

        params
      end
    end
  end
end
