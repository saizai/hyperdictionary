module PageHelper
  def type_icon page
    image_tag "#{page.page_type.name}.png", :title => page.page_type.name.capitalize, :class => 'avatar icon'
  end
end
