require_relative 'lib/mailaliaser/version'

Gem::Specification.new do |spec|
  spec.name        = 'mailaliaser'
  spec.version     = Mailaliaser::VERSION
  spec.authors     = ['Fabien Piette']
  spec.email       = ['fab.piette@gmail.com']

  spec.summary     = 'Generate unique email aliases with timestamps'
  spec.description = 'A Ruby gem for generating unique email addresses with customizable local parts, domains, and ' \
                     'timestamp suffixes'
  spec.homepage    = 'https://github.com/fabienpiette/mailaliaser'
  spec.license     = 'MIT'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{\Abin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'clipboard', '~> 1.3'
  spec.add_dependency 'slop', '~> 4.9'

  spec.required_ruby_version = '>= 2.7.0'
end
