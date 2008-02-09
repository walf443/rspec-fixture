module Spec
  module Fixture
    module Extentions
      module Example
        module ExampleGroupMethods
          def with_fixtures hash={ :input => :expected }, &fixture_block
            Spec::Fixture::Base.new(self, hash, &fixture_block).run
          end
        end
      end
    end
  end
end

Spec::ExampleGroup.instance_eval do
  extend Spec::Fixture::Extentions::Example::ExampleGroupMethods
end
