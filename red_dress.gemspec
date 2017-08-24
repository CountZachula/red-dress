Gem::Specification.new do |spec|
  spec.name          = 'red_dress'
  spec.version       = '1.0'
  spec.summary       = 'The One Challenege'
  spec.description   = 'The One Challenege'
  spec.authors       = ['Zach Harbort']
  spec.email         = ''
  spec.files       = Dir['{lib}/*']
  spec.test_files  = Dir['spec/*']
  spec.homepage = 'http://github.com/CountZachula/red-dress'

  spec.add_dependency('rubyzip')
end
