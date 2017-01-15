# Constructs a PDF of the source code of this file.

require 'code_slide'

CodeSlide::Snippet.from_file(__FILE__).
  make_pdf('simple_slide.pdf')
