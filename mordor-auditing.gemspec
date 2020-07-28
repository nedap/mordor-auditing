require './lib/auditing/version'

Gem::Specification.new do |s|
  s.name    = 'mordor-auditing'

  # Do not set the version and date field manually, this is done by the release script
  s.version = "0.1.1"
  s.date    = "2020-07-28"

  s.summary     = 'mordor-auditing'
  s.description = <<-eos
    Auditing classes based on the Mordor gem, used to audit requests and modifications on objects
  eos

  s.authors  = ['Jan-Willem Koelewijn', 'Dirkjan Bussink']
  s.email    = ['janwillem.koelewijn@nedap.com', 'dirkjan.bussink@nedap.com']
  s.homepage = 'http://www.nedap.com'

  s.add_runtime_dependency 'mordor', '~> 0.3.5'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rspec_junit_formatter'

  # The files and test_files directives are set automatically by the release script.
  # Do not change them by hand, but make sure to add the files to the git repository.
  s.files = %w(.circleci/config.yml .gitignore CHANGES.md Gemfile LICENSE README.md Rakefile lib/auditing.rb lib/auditing/modification.rb lib/auditing/request.rb lib/auditing/version.rb mordor-auditing.gemspec spec/auditing/modification_spec.rb spec/auditing/request_spec.rb spec/spec.opts spec/spec_helper.rb tasks/github-gem.rake)
end
