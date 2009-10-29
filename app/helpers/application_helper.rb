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
    BlueCloth.new(h(text)).to_html
  end
  
end