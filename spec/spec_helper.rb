# spec_helper.rb

require 'rubygems' unless RUBY_VERSION =~ /1.9.*/
require 'spec'

# add lib directory
$:.unshift File.dirname(__FILE__) + '/../lib'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
