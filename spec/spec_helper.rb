require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.start

require 'minitest/autorun'
require 'rack/test'
require_relative '../app.rb'
