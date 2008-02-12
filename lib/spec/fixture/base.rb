class Spec::Fixture::Base
  attr_reader :fixtures, :desc_template, :example_shared_runner

  def initialize binding, hash, &block
    @binding = binding
    input_names, expected_names = *hash.to_a.first
    unless input_names.kind_of? Array
      input_names = [ input_names ]
    end
    unless expected_names.kind_of? Array
      expected_names = [ expected_names ]
    end
    _define_fixture(input_names, expected_names)
    instance_eval(&block)
  end

  # This &example block was iterate as example by each fixture.
  # when you specify description for example, 
  # you can use ":" started string as template variable.
  # Template variable is expand to raw value's inspect in default 
  # expect for :msg. If you customize output message, 
  # please use +desc_filters+.
  # 
  # Block should take argumentes in order input, expected.
  # input and expected was a Hash in input has two or larger members. 
  # When input and expected has only a member, input has filtered value.
  def it desc=nil, &example
    if desc
      @desc_template = desc
    end
    @example_shared_runner = example
  end

  # You specify test data in this methods.
  # Argument should be Array that has a Hash (and string optionaly).
  # In Hasy key, you write input data and in its value you write expected data.
  def set_fixtures data
    @fixtures = data.map do |item|
      fxt, msg = *item
      input, expected = *fxt.to_a.first
      @class.new input, expected, msg, @filter_of
    end
  end

  # If you specify +filters+, you can use filtered value in +it+'s block
  # filters argument is hash that has a key of members.
  # value should be string or symbol or Array that contain strings or symbols or Proc.
  # In case value is Proc, filtered value is Proc's result.
  # In case value is Array, each item was applyed using Object#__send__.
  # In case value is string or symbol, same the above.
  def filters hash
    @filter_of = hash
  end

  # If you customize specify for example, you should use this method.
  # This methods's usage is the same as +filters+.
  def desc_filters hash
    @desc_filter_of = hash
  end

  def generate_msg fxt #:nodoc:
    if @desc_template
      msg = @desc_template
      [ fxt._members, :msg ].flatten.each do |item|
        if item == :msg
          result = fxt.msg.to_s
        else
          result = fxt.value_of[item]
          if @desc_filter_of && @desc_filter_of[item]
            if @desc_filter_of[item].kind_of? Proc
              result = @desc_filter_of[item].call(result)
            else
              [ @desc_filter_of[item] ].flatten.each do |meth|
                result = result.__send__ meth
              end
            end
          else
            result = result.inspect
          end
        end
        msg = msg.gsub(/:#{item.to_s}/, result)
      end

      msg
    else
      if fxt.msg
        fxt.msg
      else
        ""
      end
    end
  end

  def run #:nodoc:
    fixture = self
    @binding.module_eval do
      if fixture.fixtures
        fixture.fixtures.each do |fxt|
          it fixture.generate_msg(fxt) do
            fixture.example_shared_runner.call(fxt._input, fxt._expected)
          end
        end
      end
    end
  end

  # generate temp class for fixture.
  def _define_fixture input, expected #:nodoc:
    klass = Class.new
    klass.class_eval do
      attr_reader :filter_of, :value_of, :msg

      define_method :initialize do |_input, _expected, msg, filter_of|
        @value_of = {}
        @filter_of = filter_of ? filter_of : {}
        [ [input, _input], [expected, _expected] ].each do |input_or_expected|
          if input_or_expected.first.size == 1
            key = input_or_expected.first.first
            @value_of[key] = input_or_expected.last
          else
            input_or_expected.first.zip(input_or_expected.last) do |key, value|
              @value_of[key] = value
            end
          end
        end
        @msg = msg
      end

      define_method :_members do
        [ input, expected].flatten
      end

      [ [input, :_input], [expected, :_expected] ].each do |input_or_expected|
        define_method input_or_expected.last do
          if input_or_expected.first.size == 1
            __send__(input_or_expected.first.first)
          else
            result_of = {}
            input_or_expected.first.each do |item|
              result_of[item] = __send__ item
            end

            result_of
          end
        end
      end

      [ input, expected ].flatten.each do |item|
        raise NameError if instance_methods.map{|i| i.to_s }.include? item.to_s

        define_method item do
          result = @value_of[item]
          if @filter_of[item].kind_of? Proc
            result = @filter_of[item].call(result)
          else
            if @filter_of[item]
              [ @filter_of[item] ].flatten.each do |filter|
                result = result.__send__ filter
              end
            end
          end

          result
        end
      end
    end

    @class = klass
  end
end
