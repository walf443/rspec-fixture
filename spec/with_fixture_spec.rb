require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'with_fixtures' do
  it 'should defined in example group scope' do
    lambda do
      describe 'testing' do
        with_fixtures do
        end
      end
    end.should_not raise_error
  end

  it 'should work well in nested example groups' do
    lambda do
      describe 'foo' do
        describe 'bar' do
          with_fixtures do
          end
        end
      end
    end.should_not raise_error
  end

  it "should not defined in Kernel scope" do
    lambda do
      Kernel.instanse_eval do
        with_fixtures do
        end
      end
    end.should raise_error(NoMethodError)
  end
end
