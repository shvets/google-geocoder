# google_geocoder.rb

require 'open-uri'
require 'cgi'
require 'json'

# Example:
# {
#   "results"=> [
#          {"address_components"=>
#               [{"long_name"=>"Paris", "types"=>["locality", "political"], "short_name"=>"Paris"}, 
#                {"long_name"=>"Paris", "types"=>["administrative_area_level_2", "political" ], "short_name"=>"75"}, 
#                {"long_name"=>"Ile-de-France", "types"=>["administrative_area_level_1", "political"], "short_name"=>"IDF"},
#                {"long_name"=>"France", "types"=>["country", "political"], "short_name"=>"FR"}
#               ], 
#           "geometry"=>{
#               "bounds"=>{"northeast"=>{"lng"=>2.4699099, "lat"=>48.9021461}, "southwest"=>{"lng"=>2.2241006, "lat"=>48.8155414}}, 
#               "location"=>{"lng"=>2.3509871, "lat"=>48.8566667}, 
#               "location_type"=>"APPROXIMATE", 
#               "viewport"=>{"northeast"=>{"lng"=>2.4790465, "lat"=>48.915363}, "southwest"=>{"lng"=>2.2229277, "lat"=>48.7979015}}
#           },
#           "types"=>["locality", "political"], 
#           "formatted_address"=>"Paris, France"}
#   ], 
#   "status"=>"OK"
# }

module Google
  class Geocoder
    def self.Exception(*names)
      cl = Module === self ? self : Object
      names.each {|n| cl.const_set(n, Class.new(Exception))}
    end

    Exception :MissingLocation, :GeocoderServerIsDown, :InvalidResponse

    URL_STRING = "http://maps.googleapis.com/maps/api/geocode"

    def query(location)
      raise(MissingLocation) if location.nil?      
      
      request = "#{URL_STRING}/json?address=#{CGI.escape(location)}&sensor=false" 
      
      begin
        response = call_service(request)

        raise(GeocoderServerIsDown) if response.empty?
 
        if response['status'] == "ZERO_RESULTS"
          []
        else
          raise(InvalidResponse, response['results']) if response['status'] != "OK" # success

          root = response["results"][0]
          address_components = root["address_components"]
          geometry = root["geometry"]

          country = address_component(address_components, "country")
          locality = address_component(address_components, "locality")
          administrative_area_l1 = address_component(address_components, "administrative_area_level_1")
          administrative_area_l2 = address_component(address_components, "administrative_area_level_2")

          latitude = geometry["location"]["lat"]
          longitude = geometry["location"]["lng"]

          puts "Country: #{country['long_name']} (#{country['short_name']})"
          puts "Locality: #{locality['long_name']} (#{locality['short_name']})"
          puts "Administrative Area (level 1): #{administrative_area_l1['long_name']} (#{administrative_area_l1['short_name']})"
          puts "Administrative Area (level 2): #{administrative_area_l2['long_name']} (#{administrative_area_l2['short_name']})" unless administrative_area_l2.nil?

          puts "Latitude: #{latitude}"
          puts "Longitude: #{longitude}" 

          [latitude, longitude]                               
        end
      rescue OpenURI::HTTPError
        raise(GeocoderServerIsDown)
      end          
    end

    private

    def call_service(request)
      response = {}

      open(request) do |stream|
        content = stream.read

        unless content.nil?
          response = JSON.parse(content)
        end
      end

      response
    end
    
    def address_component(parent, type)
      parent.each do |child|
        if child["types"].include? type
          return child
        end
      end
      
      nil
    end
  end

end
