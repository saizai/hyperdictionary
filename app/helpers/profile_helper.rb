module ProfileHelper
  def type_icon profile
    image_tag "#{profile.profile_type.name}.png", :title => profile.profile_type.name.capitalize, :class => 'avatar icon'
  end
end
