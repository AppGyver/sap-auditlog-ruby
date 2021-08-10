# frozen_string_literal: true

require_relative "lib/sap/auditlog/version"

Gem::Specification.new do |spec|
  spec.name          = "sap-auditlog"
  spec.version       = Sap::Auditlog::VERSION
  spec.authors       = ["Richard Anderson"]
  spec.email         = ["richard.anderson@appgyver.com"]

  spec.summary       = "SAP Audit Log"
  spec.description   = "SAP Audit Log"
  spec.homepage      = "https://github.com/appgyver/sap-auditlog"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
