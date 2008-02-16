require File.join(File.dirname(__FILE__), 'spec_helper')

describe Spec::Fixture::Base do
  describe '#initialize' do
    %w(it set_fixtures filter generate_msg).each do |method|
      it "should be able to use #{method} in block" do
        Spec::Fixture::Base.new(binding, {:input => :expected }) do
          method
        end
      end
    end
  end

  before do
    @fixture_base = Spec::Fixture::Base.new(binding, {:input => :expected }) do
    end
  end

  describe '#set_fixtures' do
    it 'should convert each data to generated class instance' do
      @fixture_base.set_fixtures([
        [ {:input => :expected}, :msg ]
      ]).each do |fixture|
        fixture.should_not be_kind_of(Array)
        %w(_input _expected _members msg value_of filter_of).each do |reserved_meth|
          fixture.methods.should include(reserved_meth)
        end

        %w(input expected).each do |member|
          fixture.methods.should include(member)
        end
      end
    end
  end

  describe '#generate_msg' , "when @desc_template is nil and fixture don't have msg" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).and_return(nil)
    end

    it 'should return ""' do
      @fixture_base.generate_msg(@fxt).should == ""
    end
  end

  describe '#generate_msg' , "when @desc_template is nil and fixture have msg" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
    end

    it 'should return msg' do
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end

  describe '#generate_msg' , "when @desc_template has value and @desc_filter_of has not value" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
      @fxt.should_receive(:_members).any_number_of_times.and_return([:input, :expected])
      @fxt.should_receive(:value_of).any_number_of_times.and_return({
        :input => "raw value",
        :expected => "raw value",
      })
      @fxt.should_receive(:input).any_number_of_times.and_return("filtered value")
      @fxt.should_receive(:expected).any_number_of_times.and_return("filtered value")
    end

    it 'should convert :symbol to raw member inspect' do
      [:input, :expected].each do |member|
        @fixture_base.instance_variable_set('@desc_template', ":#{member}")
        @fixture_base.generate_msg(@fxt).should == '"raw value"'
      end
    end

    it 'should convert :msg to fixture#msg value' do
      @fixture_base.instance_variable_set('@desc_template', ':msg')
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end


  describe '#generate_msg' , "when @desc_template has value and @desc_filter_of has :symbol value" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
      @fxt.should_receive(:_members).any_number_of_times.and_return([:input, :expected])
      @fxt.should_receive(:value_of).any_number_of_times.and_return({
        :input => "raw value",
        :expected => "raw value",
      })
      @fxt.should_receive(:input).any_number_of_times.and_return("filtered value")
      @fxt.should_receive(:expected).any_number_of_times.and_return("filtered value")
      @fixture_base.instance_variable_set('@desc_filter_of', {
        :input => :upcase,
        :expected => :upcase
      })
    end

    it 'should convert :symbol to desc_filtered member value with sending symbol method to raw value' do
      [:input, :expected].each do |member|
        @fixture_base.instance_variable_set('@desc_template', ":#{member}")
        @fixture_base.generate_msg(@fxt).should == 'raw value'.upcase
      end
    end

    it 'should convert :msg to fixture#msg value' do
      @fixture_base.instance_variable_set('@desc_template', ':msg')
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end

  describe '#generate_msg' , "when @desc_template has value and @desc_filter_of has only a String that start from '.'" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
      @fxt.should_receive(:_members).any_number_of_times.and_return([:input, :expected])
      @fxt.should_receive(:value_of).any_number_of_times.and_return({
        :input => "raw value",
        :expected => "raw value",
      })
      @fxt.should_receive(:input).any_number_of_times.and_return("filtered value")
      @fxt.should_receive(:expected).any_number_of_times.and_return("filtered value")
      @fixture_base.instance_variable_set('@desc_filter_of', {
        :input => '.html_escape',
        :expected => '.html_unescape'
      })
    end

    it 'should convert :symbol to desc_filtered member value with sending symbol method to raw value' do
      [:input, :expected].each do |member|
        @fixture_base.instance_variable_set('@desc_template', ":#{member}")
        @fixture_base.generate_msg(@fxt).should == 'raw value'
      end
    end

    it 'should convert :msg to fixture#msg value' do
      @fixture_base.instance_variable_set('@desc_template', ':msg')
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end

  describe '#generate_msg' , "when @desc_template has value and @desc_filter_of has :symbol array" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
      @fxt.should_receive(:_members).any_number_of_times.and_return([:input, :expected])
      @fxt.should_receive(:value_of).any_number_of_times.and_return({
        :input => "raw value",
        :expected => "raw value",
      })
      @fxt.should_receive(:input).any_number_of_times.and_return("filtered value")
      @fxt.should_receive(:expected).any_number_of_times.and_return("filtered value")
      @fixture_base.instance_variable_set('@desc_filter_of', {
        :input => [ :upcase, :reverse ],
        :expected => [ :upcase, :reverse ],
      })
    end

    it 'should convert :symbol to desc_filtered member value with sending symbol method to raw value in array order' do
      [:input, :expected].each do |member|
        @fixture_base.instance_variable_set('@desc_template', ":#{member}")
        @fixture_base.generate_msg(@fxt).should == 'raw value'.upcase.reverse
      end
    end

    it 'should convert :msg to fixture#msg value' do
      @fixture_base.instance_variable_set('@desc_template', ':msg')
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end

  describe '#generate_msg' , "when @desc_template has value and @desc_filter_of has Proc value" do
    before do
      @fxt = mock(:fixture)
      @fxt.should_receive(:msg).any_number_of_times.and_return("fuga")
      @fxt.should_receive(:_members).any_number_of_times.and_return([:input, :expected])
      @fxt.should_receive(:value_of).any_number_of_times.and_return({
        :input => "raw value",
        :expected => "raw value",
      })
      @fxt.should_receive(:input).any_number_of_times.and_return("filtered value")
      @fxt.should_receive(:expected).any_number_of_times.and_return("filtered value")
      @proc = lambda {|val| val.upcase.reverse }
      @fixture_base.instance_variable_set('@desc_filter_of', {
        :input => @proc,
        :expected => @proc,
      })
    end

    it 'should convert :symbol to desc_filtered member value with applying Proc result' do
      [:input, :expected].each do |member|
        @fixture_base.instance_variable_set('@desc_template', ":#{member}")
        @fixture_base.generate_msg(@fxt).should == @proc.call('raw value')
      end
    end

    it 'should convert :msg to fixture#msg value' do
      @fixture_base.instance_variable_set('@desc_template', ':msg')
      @fixture_base.generate_msg(@fxt).should == "fuga"
    end
  end

  describe '#run' do
  end
end
