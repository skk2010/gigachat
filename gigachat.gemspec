# frozen_string_literal: true

require_relative 'lib/gigachat/version'

Gem::Specification.new do |spec|
  spec.name = 'gigachat'
  spec.version = GigaChat::VERSION
  spec.authors = ['Denis Smolev']
  spec.email = ['smolev@me.com']

  spec.summary = 'ruby client for GigaChat from Sberbank'
  spec.description = <<-DESC
    GigaChat
  DESC

  spec.homepage = 'https://ai.oxteam.me'
  spec.license = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 3.2.0')

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/neonix20b/gigachat'
  spec.metadata['changelog_uri'] = 'https://github.com/neonix20b/gigachat/blob/main/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '>= 1'
  spec.add_dependency 'faraday-multipart', '>= 1'
end
