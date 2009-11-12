module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end

  def focus_on_div(div)
    update_page do |page|
      page[div].focus
    end
  end
  
  def model_names
     ActiveRecord::Base.send(:subclasses).map(&:to_s).reject{|x| x =~ /:/ }.sort
  end
 
  # Just shows a check box, for display purposes only
  def check_box_only value
    check_box_tag nil, nil, value, :disabled => true
  end
  
  def full_title
    APP_NAME.humanize + (@title ? ": #{@title}" : '')
  end
  
  def markdowwn text
    BlueCloth.new(text, :auto_links => true, :safe_links => true, :strict_mode => false, :fancypants => true).to_html
  end
  
  def link_to_foo foo
    if foo.is_a? User
      link_to_user foo
    elsif foo.is_a? Badge
      render :partial => '/badges/badge', :locals => {:badge => foo}
    elsif foo.is_a? Page
      link_to_unless_current h(foo.friendly_id), page_path(foo)
    else
      link_to_unless_current h(foo.name), polymorphic_path(foo)
    end
  end
  
end