module ApplicationHelper
  def body_class
    "#{controller.controller_name} #{controller.controller_name}-#{controller.action_name}"
  end

  def logged_in_as_admin?
    logged_in? and current_user.has_role?('admin')
  end
  
  def focus_on_div(div)
    update_page do |page|
      page[div].focus
    end
  end
end