# Testing

When the repository already has a Ruby setup (a Gemfile and a `spec` directory), follow it: put the spec under `spec` as `<name>_spec.rb`, add `rspec` to the Gemfile and run it with `bundle exec rspec`.

Otherwise, put the spec beside the script as `<name>-spec.rb`, and declare RSpec with inline Bundler the same way the script declares its gems. It runs with `ruby <name>-spec.rb` and needs no Gemfile. The script's own `gemfile` block still runs when the spec loads it, so the spec only declares RSpec.

```ruby
# frozen_string_literal: true

require "bundler/inline"

gemfile do
  source "https://rubygems.org"
  gem "rspec", "~> 3.13"
end

require "rspec/autorun"
```

**REQUIRED:** Use the `ls-ruby:rspec` skill to write the specs.
