if Rails.env == 'development' 
   #config.after_initialize do
    Bullet.enable = true 
  #  Bullet.alert = true
    Bullet.bullet_logger = true  
    Bullet.console = true
    Bullet.growl = true
    Bullet.rails_logger = true
    Bullet.disable_browser_cache = true
    begin
      # run sudo gem install ruby-growl if on Mac OS
      require 'ruby-growl'
      Bullet.growl = true
      Bullet.growl_password = '6068366331a77cdbe310b42b47df29b766535cb500e5d5425c7d51ccdddf121d07940fb5a22f649c993af84d82c59a58021451686f0d894f682898e371570948'
    rescue MissingSourceFile
    end
  #end
end 