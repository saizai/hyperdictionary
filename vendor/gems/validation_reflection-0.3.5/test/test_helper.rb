# encoding: utf-8
ENV['Rails.env'] = 'test'
Rails.root = File.join(File.dirname(__FILE__))

require 'rubygems'

begin
  require 'active_record'
rescue LoadError
  gem 'activerecord', '>= 1.2.3'
  require 'active_record'
end

begin
  require 'test/unit'
rescue LoadError
  gem 'test-unit', '>= 1.2.3'
  require 'test/unit'
end