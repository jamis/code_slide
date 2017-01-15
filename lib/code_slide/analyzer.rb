require 'coderay'
require 'nokogiri'
require 'code_slide/theme_manager'

module CodeSlide
  class Analyzer
    attr_reader :elements
    attr_reader :width
    attr_reader :height
    attr_reader :styles
    attr_reader :gutter_width

    def initialize(text, options = {})
      @styles = options[:styles] ||
                (options[:theme] && ThemeManager.load_theme(options[:theme])) ||
                ThemeManager.load_theme(:light)

      line_numbers = options[:line_numbers] && :inline
      bold_every   = options[:bold_every] || nil
      line_start   = options[:line_number_start] || 1

      text = _preprocess_text(text)
      _compute_gutter(line_numbers, line_start)
      html = _generate_html(text, options[:lang],
                            line_numbers, line_start, bold_every)

      _format_html(html)
    end

    def _compute_gutter(line_numbers, line_start)
      @gutter_width = 0
      return unless line_numbers

      max = line_start + height
      @gutter_width = Math.log10(max + 1).ceil + 1
    end

    def _generate_html(text, lang, line_numbers, line_start, bold_every)
      CodeRay.scan(text, lang).
        html(line_numbers: line_numbers,
             line_number_anchors: false,
             line_number_start: line_start,
             bold_every: bold_every).
        gsub(%r{</strong>}, '</span>').
        gsub(/<strong>/, '<span class="highlight">')
    end

    # removes leading and trailing blank lines
    def _preprocess_text(text)
      lines = text.lines.map(&:rstrip)
      lines.delete_at(0) while lines[0].empty?
      lines.delete_at(-1) while lines[-1].empty?

      @width = lines.map(&:length).max
      @height = lines.length

      lines.join("\n")
    end

    def _format_html(html)
      doc = Nokogiri::HTML.fragment(html)

      @current_attributes = [{}]
      @elements = []

      _format(doc)
    end

    def _format(parent)
      style = _lookup_class(parent['class'])
      @current_attributes.push(_merge_style(style))
      parent.children.each { |child| _format_node(child) }
    ensure
      attrs = @current_attributes.pop
      @elements.last[:text] << attrs[:after] if attrs[:after]
    end

    def _format_node(node)
      if node.text?
        @elements << _style(node)
      elsif node.element?
        _format(node)
      else
        raise 'unknown node type'
      end
    end

    def _style(node)
      text = _text(node)
      attrs = @current_attributes.last
      attrs.merge(text: text)
    end

    def _merge_style(style)
      styles = @current_attributes.last[:styles]
      if style[:styles]
        styles ||= []
        styles = [*style[:styles], *styles]
      end

      @current_attributes.last.merge(style).tap do |attrs|
        attrs[:styles] = styles if styles

        # 'after' is never inherited
        attrs[:after] = nil unless style[:after]
      end
    end

    def _lookup_class(class_name)
      return (@styles[:default] || {}) unless class_name

      class_name && (@styles[class_name] || @styles[class_name.to_sym]) ||
        begin
          warn "no definition for #{class_name}"
          { class: class_name }
        end
    end

    ENTITY = {
      'lt'   => '<',
      'gt'   => '>',
      'amp'  => '&'
    }.freeze

    def _text(text)
      text.to_s.
        tr(' ', "\u00A0").
        gsub(/\&(.*?);/) do |match|
          entity = Regexp.last_match(1)
          ENTITY[entity.downcase] || match
        end
    end
  end
end
