require 'spec'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/spec/fixture'))

def detect_location point
end

describe "detect_location" do
  with_fixtures do
    it 'should detect point (:x, :y) to :location' do |x,y, location|
      detect_location([x,y]).should == location
    end

    set_fixtures({[:x, :y] => :location }, [
      [ { [1,0] => 'right' }, '' ],
      [ { [-1,0] => 'left' }, '' ],
      [ { [0,1] => 'top' }, '' ],
      [ { [0,- 1] => 'bottom' }, '' ],
    ])
  end
end
