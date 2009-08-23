$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'technical_debt'
require 'spec'
require 'spec/autorun'
require 'git_diffs'
require 'active_support'

Spec::Runner.configure do |config|
  include GitDiffs
end
