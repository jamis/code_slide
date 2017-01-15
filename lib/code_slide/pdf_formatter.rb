require 'prawn'

module CodeSlide
  class PDFFormatter
    def initialize(analyzer)
      @analyzer = analyzer
    end

    def use_font(path, bold: path, italic: path, bold_italic: path)
      @font = path
      @bold = bold
      @italic = italic
      @bold_italic = bold_italic

      self
    end

    def build_pdf(gravity: :center,
                  background_color: nil,
                  font_size: 16, page_width: 792, page_height: 612)
      Prawn::Document.new(page_size: [page_width, page_height]).tap do |pdf|
        Prawn::Font::AFM.hide_m17n_warning = true

        _prepare_background(pdf, background_color)
        pdf.font _prepare_font(pdf), size: font_size
        options = _prepare_options(pdf, gravity)

        box = Prawn::Text::Formatted::Box.new(@analyzer.elements, options)
        box.render
      end
    end

    def _prepare_background(pdf, bgcolor)
      bgcolor ||= @analyzer.styles[:background] &&
                  @analyzer.styles[:background][:color]
      return unless bgcolor

      pdf.canvas do
        pdf.fill_color bgcolor
        pdf.fill_rectangle [pdf.bounds.left, pdf.bounds.top],
                           pdf.bounds.right, pdf.bounds.top
      end
    end

    def _prepare_font(pdf)
      if @font.nil?
        'Courier'
      else
        pdf.font_families.update(
          'Custom' => { normal: @font,
                        bold: @bold,
                        italic: @italic,
                        bold_italic: @bold_italic })
        'Custom'
      end
    end

    def _prepare_options(pdf, gravity)
      width = pdf.width_of('M') * @analyzer.width
      height = pdf.height_of('M') * @analyzer.height

      width += @analyzer.gutter_width

      {
        document: pdf,
        overflow: :overflow,
        at: _box_position(pdf, width, height, gravity)
      }
    end

    def _box_position(pdf, width, height, gravity)
      left    = 0
      hcenter = (pdf.bounds.width - width) / 2
      right   = pdf.bounds.width - width
      top     = pdf.bounds.height
      vcenter = pdf.bounds.height - (pdf.bounds.height - height) / 2
      bottom  = height

      case gravity
      when :northwest then [left,    top    ]
      when :north     then [hcenter, top    ]
      when :northeast then [right,   top    ]
      when :west      then [left,    vcenter]
      when :center    then [hcenter, vcenter]
      when :east      then [right,   vcenter]
      when :southwest then [left,    bottom ]
      when :south     then [hcenter, bottom ]
      when :southeast then [right,   bottom ]
      else raise ArguentError, "unsupported gravity #{gravity.inspect}"
      end
    end
  end
end
