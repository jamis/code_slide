require 'code_slide/analyzer'
require 'code_slide/pdf_formatter'
require 'code_slide/png_formatter'

module CodeSlide
  class Snippet
    def self.from_file(filename, options = {})
      options = options.dup

      start = options.delete(:start) || 1
      finish = options.delete(:finish) || -1

      line_start = options[:line_number_start] || start

      # assume people number their file lines starting at 1
      start -= 1 if start > 0
      finish -= 1 if finish > 0

      text = File.read(filename).lines[start..finish].join
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
