# Demonstrates some of the configuration options that are
# available to CodeSlide.

require 'code_slide'

font_path = File.join(File.dirname(__FILE__), 'fonts', 'hack')

CodeSlide::Snippet.
  from_file(__FILE__,
            theme: :dark,
            line_numbers: true,
            bold_every: 5).
  use_font(File.join(font_path, 'Hack-Regular.ttf'),
           bold: File.join(font_path, 'Hack-Bold.ttf'),
           italic: File.join(font_path, 'Hack-Italic.ttf'),
           bold_italic: File.join(font_path, 'Hack-BoldItalic.ttf')).
  make_pdf('configuration.pdf',
           gravity: :west,
           font_size: 24,
           page_width: 1600,
           page_height: 900)
