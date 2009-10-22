module ContactTypeHelper
  def contact_icon contact_type
    if %w(email aim yahoo jabber livejournal icq msn).include? contact_type.name.downcase
      image_tag "#{contact_type.name.downcase}.png", :title => contact_type.name
    elsif contact_type.meta_type == 'phone'
      image_tag 'phone.png', :title => contact_type.name
    else
      '&nbsp;'
    end
  end
end
