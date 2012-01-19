Gem::Specification.new do |s|
  s.name    = "mordor-auditing"
  
  # Do not set the version and date field manually, this is done by the release script
  s.version = "0.0.13"
  s.date    = "2012-01-04"

  s.summary     = "mordor-auditing"
  s.description = <<-eos
    Auditing classes based on the Mordor gem, used to audit requests and modifications on objects
  eos

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 2.0')

  s.add_development_dependency('mordor', '0.2.10')

  s.add_runtime_dependency('mordor', '0.2.10')

  s.authors  = ['Jan-Willem Koelewijn', 'Dirkjan Bussink']
  s.email    = ['janwillem.koelewijn@nedap.com', 'dirkjan.bussink@nedap.com']
  s.homepage = 'http://www.nedap.com'

  # The files and test_files directives are set automatically by the release script.
  # Do not change them by hand, but make sure to add the files to the git repository.
  s.files = %w(.gitignore Gemfile Gemfile.lock Rakefile auditing.gemspec lib/auditing.rb lib/auditing/modification.rb lib/auditing/request.rb lib/auditing/version.rb spec/auditing/modification_spec.rb spec/auditing/request_spec.rb spec/spec.opts spec/spec_helper.rb tasks/github-gem.rake)
end
