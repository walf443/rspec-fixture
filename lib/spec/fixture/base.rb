class Spec::Fixture::Base
  attr_reader :fixtures, :desc_template, :example_shared_runner

  def initialize binding, &block
    @binding = binding
    instance_eval(&block)
  end

  def it desc=nil, &example
    if desc
      @desc_template = desc
    end
    @example_shared_runner = example
  end

  def set_fixtures fmt, data
    @fixture_format = fmt
    @fixtures = data
  end

  def run
    fixture = self
    @binding.module_eval do
      fixture.fixtures.each do |fxt|
        it fixture.desc_template do
          fixture.example_shared_runner.call(fxt.first.to_a.flatten)
        end
      end
    end
  end
end
