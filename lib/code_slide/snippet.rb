require 'code_slide/analyzer'
require 'code_slide/pdf_formatter'
require 'code_slide/png_formatter'

module CodeSlide
  class Snippet
    MARK_PREFIX = %r{^\s*(#|//)\s*}
    START_MARK  = /#{MARK_PREFIX}START:\s*/
    END_MARK    = /#{MARK_PREFIX}END:\s*/

    def self.from_file(filename, options = {})
      options = options.dup

      lines = File.readlines(filename)
      mark = options.delete(:mark)

      if mark
        start = lines.index { |line| line =~ /#{START_MARK}#{mark}\s*$/i }
        finish = lines.index { |line| line =~ /#{END_MARK}#{mark}\s*$/i }

        # if start is defined, don't include the comment itself
        start += 2 if start
      else
        start = options.delete(:start)
        finish = options.delete(:finish)
      end

      start ||= 1
      finish ||= -1
      line_start = options[:line_number_start] || start

      # assume people number their file lines starting at 1
      start -= 1 if start > 0
      finish -= 1 if finish > 0

      text = lines[start..finish].join

      if options.delete(:strip_indent)
        indent = text[/^\s*/]
        text.gsub!(/^#{indent}/m, "")
      end

      new(text,
          options.merge(lang: options[:lang] || detect_language_type(filename),
                        line_number_start: line_start))
    end

    EXTMAP = { # rubocop:disable Style/MutableConstant
      '.rb'   => :ruby,
      '.py'   => :python,
      '.c'    => :c,
      '.java' => :java
    }

    def self.detect_language_type(filename)
      EXTMAP[File.extname(filename).downcase]
    end

    def initialize(snippet, options = {})
      @analyzer = CodeSlide::Analyzer.new(snippet, options)
      use_font(nil)
    end

    def use_font(path, bold: path, italic: path, bold_italic: path)
      @font = path
      @bold = bold
      @italic = italic
      @bold_italic = bold_italic

      self
    end

    def make_pdf(filename, options = {})
      PDFFormatter.new(@analyzer).
        use_font(@font, bold: @bold,
                        italic: @italic,
                        bold_italic: @bold_italic).
        build_pdf(options).
        render_file(filename)
    end

    def make_png(filename, options = {})
      options = options.dup
      dpi = options.delete(:dpi)
      keep_pdf = options.delete(:keep_pdf)

      pdf_name = File.basename(filename, File.extname(filename)) + '.pdf'

      make_pdf(pdf_name, options)
      PNGFormatter.new(pdf_name).
        generate_png(filename, dpi: dpi)
      File.delete(pdf_name) unless keep_pdf
    end
  end
end
