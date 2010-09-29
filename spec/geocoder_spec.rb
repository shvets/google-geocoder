# geocoder_spec.rb

require File.dirname(__FILE__) + '/spec_helper'

require 'google_geocoder'

module Google

  describe Geocoder do
    before :each do
      @geocoder = Geocoder.new
    end

    it "should raise an error if parameter is missing" do
      lambda {
        @geocoder.query(nil)
      }.should raise_error
    end
    
    it "should return geocode coordinates" do
      q = @geocoder.query("moscow russia")

      puts q

      q.size.should be == 2
    end
  end

end
