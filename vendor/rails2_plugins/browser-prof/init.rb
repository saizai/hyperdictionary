class ActiveRecord::Base
  def self.inspect
    "#<#{name}#>"
  end
end

require 'browser-prof'
