module ActsAsPreferenced
  
  PREFERENCE_REGEX = /(\w+)_preference([=]?)$/

  def self.included(base) # :nodoc:
     base.extend ClassMethods
  end
  
  module ClassMethods
    def acts_as_preferenced(options = {})
      # don't allow multiple calls
      return if self.included_modules.include?(ActsAsPreferenced::InstanceMethods)
      
      # associated preferences
      has_many :preferences, :dependent => :destroy, :as => :preferrer do
        # provides a way to get all preferences scoped to a specific object
        def for(obj)
          if obj.is_a? Class
            find :all, :conditions => { :preferred_type => obj.to_s, :preferred_id => nil }        
          else
            find :all, :conditions => { :preferred_type => obj.class.to_s, :preferred_id => obj.id }
          end
        end
      end

      # and finally our lovely instance methods
      include ActsAsPreferenced::InstanceMethods
    end
  end
  
  module InstanceMethods
    
    # Set a preference within the context of this user
    # obj can be an object or class and name must be a string
    # you may additionally pass a hash to create several preferences at once
    def set_preference(name, value=nil, obj=self)
      value = nil if value.blank?
      if name.is_a? Hash
        pref, prefs = nil, []
        name.keys.each{|key| prefs << pref = set_preference(key.to_s, name[key], obj) } and return prefs.size > 1 ? prefs : pref
      end
      if pref = preferences.for(obj).find{|p| p.name == name }
        pref.update_attribute(:value, value)
      elsif obj.is_a? Class
        pref = preferences.create( :preferred_type => obj.to_s, :name => name, :value => value )
      else
        pref = preferences.create( :preferred => obj, :name => name, :value => value )
      end
      pref
    end
  
    # Returns selected preference value
    def get_preference(name, obj=self)
      (x = preferences.for(obj).find{|p| p.name == name.to_s }).nil? ? nil : x.value
    end
  
  protected

    # check for dynamic preference methods
    def method_missing(symbol, *args)
      if symbol.to_s =~ PREFERENCE_REGEX
        process_preference_request(symbol, args)
      else
        super
      end
    end
  
    # either sets or returns the preference based on the request
    def process_preference_request(symbol, *args)
      args.flatten!
      name = symbol.to_s.gsub(PREFERENCE_REGEX,'\\1\\2')
      if name =~ /=$/
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 1)") if args.size != 1
        set_preference(name.gsub(/=$/,''), args[0])
      else
        raise ArgumentError.new("wrong number of arguments (#{args.size} for 0)") if args.size != 0
        get_preference(name)
      end
    end

  end  
end
