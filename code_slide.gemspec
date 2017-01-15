$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'code_slide/version'

Gem::Specification.new do |s|
  s.name        = 'code_slide'
  s.version     = CodeSlide::VERSION
  s.authors     = ['Jamis Buck']
  s.email       = ['jamis@jamisbuck.org']
  s.homepage    = 'https://github.com/jamis/code_slide'
  s.summary     = 'Generate PDF/PNG slides from source code'
  s.license     = 'MIT'
  s.description = <<-DESC
    A library for turning code snippets into slides. Automatically turn your
    source code into syntax-highlighted PDFs and PNGs. Take the tedium out
    of building your presentation's slide deck!
  DESC

  s.files = Dir['lib/**/*', 'MIT-LICENSE', 'README.md']

  s.add_dependency 'prawn', '~> 2.1'
  s.add_dependency 'coderay', '~> 1.1'
  s.add_dependency 'nokogiri', '~> 1.6'
end
