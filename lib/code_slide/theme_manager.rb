require 'yaml'

module CodeSlide
  class ThemeManager
    @search_paths = []
    @search_paths << '.'
    @search_paths << File.join(File.dirname(__FILE__), 'themes')

    @cached_themes = {}

    class <<self
      attr_reader :search_paths

      def load_theme(name)
        @cached_themes[name] ||= begin
          file_name = "#{name}.yml"
          path = @search_paths.
                 map { |s| File.join(s, file_name) }.
                 find { |s| File.exist?(s) }

          if path.nil?
            raise ArgumentError, "couldn't find theme #{name.inspect}"
          end

          _post_process(YAML.load_file(path))
        end
      end

      def _post_process(hash)
        hash.each.with_object({}) do |(key, value), result|
          key = key.to_sym
          result[key] = _post_process_value(key, value)
        end
      end

      def _post_process_value(key, value)
        if key == :styles
          value.map(&:to_sym)
        elsif value.is_a?(Hash)
          _post_process(value)
        else
          value
        end
      end
    end
  end
end
