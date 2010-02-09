f = if File.exists?  File.join(Rails.root, 'db', 'GeoLiteCity.dat') # prefer the more contentful database if present
  GEOIP_CITY = true
  File.join(Rails.root, 'db', 'GeoLiteCity.dat')
elsif File.exists?  File.join(Rails.root, 'db', 'GeoIP.dat')
  GEOIP_CITY = false
  File.join(Rails.root, 'db', 'GeoIP.dat')
else
  raise "Couldn't find main GeoIP database in db/. Download it from:
    http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz # gives city and country data
    http://www.maxmind.com/download/geoip/database/GeoIP.dat.gz # gives country data only, but is smaller"
end

# GEOIP = GeoIP.new(f)

# Note that the country version returns:
# g.country('4.2.2.2')
#        query, ip, GeoIP country ID, 2char country code, 3char country code, country name, 2 char continent code
#    => ["4.2.2.2", "4.2.2.2", 225, "US", "USA", "United States", "NA"]
# whereas city returns:
#        query, IP, 2char country code, 3char country code, country name, 2char contintent code, region name, city name, postal code, latitude, longitude, USA area/dma code
#    => ["4.2.2.2", "4.2.2.2", "US", "USA", "United States", "NA", "", "", "", 38.0, -97.0, 0, 0]
# ... so yeah, boo inconsistency. But for convenience:

def GEO_COUNTRY ip
  if GEOIP_CITY
    GEOIP.country(ip)[2]
  else
    GEOIP.country(ip)[3]
  end
end

if File.exists?  File.join(Rails.root, 'db', 'GeoIPASNum.dat')
  # note that the GeoIP ASN database kinda sucks. Not as good as whois or Team Cymru's database :-/
#  GEOIP_ASN = GeoIP.new(File.join(Rails.root, 'db', 'GeoIPASNum.dat'))
else
#  p "Couldn't find GeoIP ASN database in db/. Download it from http://geolite.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz if you care."  
end

# Note other useful DBs:
# http://www.maxmind.com/download/worldcities/worldcitiespop.txt.gz # 2-letter country code, city, accented city, region, population, latitude, longitude 123 MB.
# http://pablotron.org/files/zipcodes-csv-10-Aug-2004.zip  #  US ZIP codes: zip, city, state, latitude, longitude, GMT timezone offset, and daylight savings time flag 2.4 MB
# http://geocoder.ibegin.com/downloads/zip5.zip # all US ZIP codes.  zip, city, state, latitude, longitude, and county # 1.9 MB
# http://geocoder.ibegin.com/downloads/us_cities.zip # city name, state/province, latitude, and longitude # 8.1 MB
# http://geocoder.ibegin.com/downloads/canada_cities.zip # 523 KB