module CodeSlide
  class PNGFormatter
    def initialize(pdf_filename)
      @pdf_filename = pdf_filename
    end

    def generate_png(filename, dpi: 300, keep_pdf: false)
      system 'gs -q -sDEVICE=png16m -dTextAlphaBits=4 ' \
             "-r#{dpi} -o #{filename} #{@pdf_filename}"
    end
  end
end
