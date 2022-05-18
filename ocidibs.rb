#!/usr/bin/env ruby

# Install required gems using bundler
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'oci', require: 'oci'
end

if __FILE__ == $0
  puts "Hello, world!"
end
