Gem::Specification.new do |spec|
	spec.name        = 'rind'
	spec.version     = '0.1.2'
	spec.summary     = 'A templating engine that turns HTML (and XML) into node trees and allows you to create custom tags.'
	spec.description = 'Rind is a templating engine that turns HTML (and XML) into node trees and allows you to create custom tags or reuse someone else’s genius. Rind gives web devs tags to work with and provides the same thing to app devs as an object. This project is just getting started so watch out for sharp corners and unfinished rooms.'

	spec.authors  = 'Aaron Lasseigne'
	spec.email    = 'aaron.lasseigne@gmail.com'
	spec.homepage = 'http://github.com/AaronLasseigne/Rind'

	spec.test_files = Dir['test/*.rb'] + Dir['test/files/*']
	spec.files      = Dir['lib/**/*.rb'] + ['README.rdoc', 'LICENSE', 'CHANGELOG.rdoc'] + spec.test_files

	spec.has_rdoc     = true
	spec.rdoc_options = ["--quiet"]
end
