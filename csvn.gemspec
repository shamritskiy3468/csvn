require_relative 'lib/csvn/version'

Gem::Specification.new do |spec|
  spec.name          = "csvn"
  spec.version       = Csvn::VERSION
  spec.authors       = ["shamritskiy3468"]
  spec.email         = ["sshamritskiy3468@gmail.com"]

  spec.summary       = %q{Attemp to simplify routine work with CSV files (such as DB request result)}
  spec.description   = %q{My simple gem for work with .csv data files. Can read data from files with any separator and allow work with them more comfortable.}
  spec.homepage      = "https://github.com/shamritskiy3468/csvn"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shamritskiy3468/csvn"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "colorize", "= 0.8.1"
end
