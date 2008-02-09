require 'spec'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/spec/fixture'))

class Point
  def initialize x, y
    @x, @y = x, y
  end

  def detect_location
    return 'unknown'
  end

  def to_s
    "( #@x, #@y )"
  end
end

describe Point, "detect_location" do
  with_fixtures [:x, :y] => :location do
    filters({ 
      :location => [:to_s, ] 
    })

    it 'should detect point (:x, :y) to :location (:msg)' do |input, location|
      Point.new(input[:x], input[:y]).detect_location.should == location
    end

    set_fixtures([
      [ [1,   0]  => :right  ],
      [{[-1,  0]  => :left }, "border"  ],
      [{[-0.5,0]  => :left }, "inner" ],
      [ [0,   1]  => :top  ],
      [ [0,  -1]  => :bottom ],
    ])
  end
end

# you can also write following.
describe Point, "detect_location" do
  with_fixtures :point => :location do
    filters({
      :point    => lambda { |val| Point.new(*val).detect_location },
      :location => :to_s,
    })

    it "should detect point :point to :location (:msg)" do |point, location|
      point.should == location
    end

    set_fixtures([
      [ [1,   0]  => :right  ],
      [{[-1,  0]  => :left }, "border"  ],
      [{[-0.5,0]  => :left }, "inner" ],
      [ [0,   1]  => :top  ],
      [ [0,  -1]  => :bottom ],
    ])
  end
end

# If you skip with_fixtures argments, { :input => :expected } was use as default
describe Point, "detect_location" do
  with_fixtures do
    filters({
      :input => lambda {|val| Point.new(*val).detect_location },
      :expected => :to_s,
    })

    it "should detect point :input to :expected (:msg)" do |input, expected|
      input.should == expected
    end

    set_fixtures([
      [ [1,   0]  => :right  ],
      [{[-1,  0]  => :left }, "border"  ],
      [{[-0.5,0]  => :left }, "inner" ],
      [ [0,   1]  => :top  ],
      [ [0,  -1]  => :bottom ],
    ])
  end
end
