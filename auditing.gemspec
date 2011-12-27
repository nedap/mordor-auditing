Gem::Specification.new do |s|
  s.name    = "auditing"
  
  # Do not set the version and date field manually, this is done by the release script
  s.version = "0.0.1"
  s.date    = "2011-12-27"

  s.summary     = "auditing"
  s.description = <<-eos
    description
  eos

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.0')

  s.add_development_dependency('mordor', '0.2.1')

  s.add_runtime_dependency('mordor', '0.2.1')

  s.authors  = ['Jan-Willem Koelewijn', 'Dirkjan Bussink']
  s.email    = ['janwillem.koelewijn@nedap.com', 'dirkjan.bussink@nedap.com']
  s.homepage = 'http://www.nedap.com'

  # The files and test_files directives are set automatically by the release script.
  # Do not change them by hand, but make sure to add the files to the git repository.
  s.files = %w(.gitignore Gemfile Gemfile.lock Rakefile auditing.gemspec lib/auditing.rb lib/auditing/modification.rb lib/auditing/request.rb lib/auditing/version.rb spec/auditing/modification_spec.rb spec/auditing/request_spec.rb spec/spec.opts spec/spec_helper.rb tasks/github-gem.rake)
end
