require 'spec'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../')))

module Spec
  module Fixture
  end
end

require 'spec/fixture/base'
require 'spec/fixture/extentions/example/example_group_methods'
