# CodeSlide

A library for turning code snippets into slides. Automatically turn your
source code into syntax-highlighted PDFs and PNGs. Take the tedium out of
building your presentation's slide deck!


## Installation

If you want to be able to automatically generate PNG files, you'll need to have
GhostScript installed (https://ghostscript.com/).

Aside from that, installation is as easy as:

    $ gem install code_slide

And you're good to go!


## Usage

Look in the `examples` directory for some demonstrations of CodeSlide. In
brief, though, it works like this:

```ruby
require 'code_slide'

snippet = CodeSlide::Snippet.new(<<-RUBY, lang: :ruby)
1.upto(100) do |n|
  print 'Fizz' if (n % 3).zero?
  print 'Buzz' if (n % 5).zero?
  puts if (n % 3).zero? || (n % 5).zero?
end
RUBY

snippet.make_pdf('snippet.pdf')
```

You can also source your snippet from a file directly, even specifying which
range of lines you want to use:

```ruby
snippet = CodeSlide::Snippet.from_file('fizz-buzz.rb', start: 5, finish: 15)
snippet.make_pdf('snippet.pdf')
```

If you have a (TTF) font you want to use, you can specify the different faces
in the family, and instruct CodeSlide to use them:

```ruby
snippet = CodeSlide::Snippet.from_file('fizz-buzz.rb', start: 5, finish: 15)
snippet.use_font('myfont-regular.ttf',
                 bold: 'myfont-bold.ttf',
                 italic: 'myfont-italic.ttf',
                 bold_italic: 'myfont-bold-italic.ttf')
snippet.make_pdf('snippet.pdf')
```

You can choose between the "light" and "dark" themes (or make your own):

```ruby
snippet = CodeSlide::Snippet.from_file('fizz-buzz.rb', theme: :dark)
snippet.make_pdf('dark-snippet.pdf')
```

And if you want to generate a PNG directly, you can do that too (though again,
you need to have GhostScript installed):

```ruby
snippet.make_png('snippet.png')
```


## License

This software is released under the terms of the MIT license. See the
`MIT-LICENSE` for full details.


## Author

This software is written and distributed by Jamis Buck <jamis@jamisbuck.org>.
