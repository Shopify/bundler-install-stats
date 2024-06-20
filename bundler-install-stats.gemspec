# frozen_string_literal: true

require_relative "lib/bundler_install_stats/version"

Gem::Specification.new do |spec|
  spec.name          = "bundler_install_stats"
  spec.version       = BundlerInstallStats::VERSION
  spec.authors       = ["Shopify Engineering"]
  spec.email         = ["gems@shopify.com"]

  spec.summary       = "A Bundler plugin for measuring gem installation stats."
  spec.description   = "A plugin for measuring gem installation stats. Discover which are your slowest gems to install."
  spec.homepage      = "https://github.com/Shopify/bundler-install-stats"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/releases"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    %x(git ls-files -z).split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
