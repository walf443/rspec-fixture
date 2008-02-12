require File.join(File.dirname(__FILE__), 'spec_helper')

shared_examples_for 'generated_class' do
  # reserverd methods
  %w(_input _expected _members filter_of value_of msg).each do |method|
    it "should have #{method} instance method" do
      @class.instance_methods.map {|i| i.to_s }.should include(method)
    end
  end

  it "should have instance method in each members" do
    @class_instance._members.each do |member|
      @class.instance_methods.map {|i| i.to_s }.should include(member.to_s)
    end
  end

end

describe Spec::Fixture::Base do
  describe '#_define_fixture' do
    before do
      @fixuture_base = Spec::Fixture::Base.allocate 
    end

    it 'should generate some class' do
      @fixuture_base._define_fixture([:foo], [:bar]).should be_kind_of(Class)
    end

    %w(_input _expected _members filter_of value_of msg).each do |reserved_name|
      it "should raise NameError when using  #{reserved_name} for arguments" do
        lambda {
          @fixuture_base._define_fixture([reserved_name], [:foo])
        }.should raise_error(NameError)
      end
    end

    it 'should raise NameError when specify same name for arguments' do
      lambda {
        @fixuture_base._define_fixture([:foo], [:foo])
      }.should raise_error(NameError)
    end

    describe 'generated class', 'when one input, one expected' do
      before do
        @class = @fixuture_base._define_fixture([:foo], [:bar])
        @class_instance = @class.new([:foo], [:bar], nil, nil)
      end

      it_should_behave_like 'generated_class'

      it 'should have members list' do
        @class_instance._members.should == [:foo, :bar]
      end

      it 'should return same value between expected member and _expected method' do
        @class_instance._expected.should == @class_instance.bar
      end

      it 'should return same value between input member and _input method' do
        @class_instance._input.should == @class_instance.foo
      end
    end

    describe 'generated class', 'when two input, one expected' do
      before do
        @class = @fixuture_base._define_fixture([:foo, :bar], [:baz])
        @class_instance = @class.new([:foo, :bar], [:baz], nil, nil)
      end

      it_should_behave_like 'generated_class'

      it 'should have members list' do
        @class_instance._members.should == [:foo, :bar, :baz]
      end

      it 'should return same value between expected member and _expected method' do
        @class_instance._expected.should == @class_instance.baz
      end

      it '_input method should return input members method result Hash' do
        @class_instance._input.should == { 
          :foo => @class_instance.foo, 
          :bar => @class_instance.bar 
        }
      end
    end

    describe 'generated class', 'when two input, two expected' do
      before do
        @class = @fixuture_base._define_fixture([:foo, :bar], [:baz, :zoo])
        @class_instance = @class.new([:foo, :bar], [:baz, :zoo], nil, nil)
      end

      it_should_behave_like 'generated_class'

      it 'should have members list' do
        @class_instance._members.should == [:foo, :bar, :baz, :zoo]
      end

      it '_expected method should return expected members method result Hash' do
        @class_instance._expected.should == { 
          :baz => @class_instance.baz, 
          :zoo => @class_instance.zoo 
        }
      end

      it '_input method should return input members method result Hash' do
        @class_instance._input.should == { 
          :foo => @class_instance.foo, 
          :bar => @class_instance.bar 
        }
      end
    end
    
    describe 'generated class with filter', 'when filter value is only simbol' do
      before do
        @class = @fixuture_base._define_fixture([:foo], [:bar])
        filter = {
          :foo => :to_s,
          :bar => :inspect,
        }
        @class_instance = @class.new(:foo, :bar, nil, filter)
      end

      it_should_behave_like 'generated_class'

      it 'should be applyed filter with sending symbol to raw value' do
        @class_instance.foo.should == 'foo'
        @class_instance._input.should == 'foo'
        @class_instance.bar.should == ':bar'
        @class_instance._expected.should == ':bar'
      end
    end

    describe 'generated class with filter', 'when filter value with symbol array' do
      before do
        @class = @fixuture_base._define_fixture([:foo], [:bar])
        filter = {
          :foo => [ :to_s, :inspect ],
          :bar => [ :to_s, :capitalize, :to_sym ]
        }
        @class_instance = @class.new([:foo], [:bar], nil, filter)
      end

      it_should_behave_like 'generated_class'

      it 'should be applyed filter with sending symbol in order array to raw value' do
        @class_instance.foo.should == '"foo"'
        @class_instance._input.should == '"foo"'
        @class_instance.bar.should == :Bar
        @class_instance._expected.should == :Bar
      end
    end

    describe 'generated class with filter', 'when filter value with Proc' do
      before do
        @class = @fixuture_base._define_fixture([:foo], [:bar])
        filter = {
          :foo => lambda {|val| val.to_s.capitalize.reverse },
          :bar => lambda {|val| val.to_s.size }
        }
        @class_instance = @class.new([:foo], [:bar], nil, filter)
      end

      it_should_behave_like 'generated_class'

      it 'should be applyed filter with executing Proc' do
        @class_instance.foo.should == 'ooF'
        @class_instance._input.should == 'ooF'
        @class_instance._expected.should == 3
      end
    end
  end
end
