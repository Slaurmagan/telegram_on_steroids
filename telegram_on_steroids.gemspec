require_relative 'lib/telegram_on_steroids/version'

Gem::Specification.new do |spec|
  spec.name          = "telegram_on_steroids"
  spec.version       = TelegramOnSteroids::VERSION
  spec.authors       = ["Aliaksandr Hrakovich"]

  spec.summary       = %q{A simple library to create Telegram Bots in Ruby.}
  spec.homepage      = "https://github.com/slaurmagan/telegram_on_steroids"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.4.0")

  spec.add_development_dependency "activesupport", "~> 5.2.0"
  spec.add_dependency "http"
  spec.add_dependency "retryable"
  spec.add_dependency "oj"
  spec.add_dependency 'redis'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.require_paths = ["lib"]
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|example)/}) }
  end

  spec.license       = "MIT"
end
