class FourOhFour < ActiveRecord::Base
  acts_as_paranoid
  
  def self.add_request(url, referer)
    request = find_or_initialize_by_url_and_referer(url, referer)
    request.count += 1
    request.save
  end
end

