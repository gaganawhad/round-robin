# frozen_string_literal: true
source 'https://rubygems.org'
git_source(:github) { |repo_name| "https://github.com/#{repo_name}.git" }

# When updating, please ensure you test the upgrade with a deploy to staging before submitting a PR.
ruby '2.3.1'

gem 'redis'

group :development do
  gem 'guard-rspec', require: nil
  gem 'guard-rubocop'
end

group :test, :development do
  gem 'rspec'
  gem 'rubocop'
end
