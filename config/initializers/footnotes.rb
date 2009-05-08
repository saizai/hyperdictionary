# See http://github.com/josevalim/rails-footnotes/tree/master

# If not using TextMate, replace 'txmt://open?url=file://%s&line=%d&column=%d' with something from:
#   http://josevalim.blogspot.com/2008/06/textmate-protocol-behavior-on-any.html
#  if defined?(Footnotes)
#    # %d = line number; %d #2 = column; %s = file name
#    Footnotes::Filter.prefix = 'txmt://open?url=file://%s&line=%d&column=%d'
#  end

# Styling option 1 - put this in your layout:
#  <div id='footnotes_holder'></div>
# Styling option 2:
#   Footnotes::Filter.no_style = true
# Other options:
#  Footnotes::Filter.multiple_notes = true # allow multiple notes open at once
#  Footnotes::Filter.notes = [:session, :cookies, :params, :filters, :routes, :env, :queries, :log, :general] # don't have some of the defaults


# By default the plugin only is active in dev mode.
# I want it to be active in dev mode OR if I'm logged in as an admin.

# First ('cause this supercedes them and they'd cause a conflict if they still exist):
footnotes_dir = File.join(RAILS_ROOT, 'vendor', 'plugins', 'rails-footnotes')
[File.join(footnotes_dir, 'init.rb'), 
 File.join(footnotes_dir, 'lib', 'rails-footnotes.rb')].each do |init_file|
  File.delete init_file if File.exists? init_file
end
require File.join(footnotes_dir, 'lib', 'rails-footnotes', 'footnotes.rb')
require File.join(footnotes_dir, 'lib', 'rails-footnotes', 'backtracer.rb')
# Load all notes
Dir[File.join(footnotes_dir, 'lib', 'rails-footnotes', 'notes', '*.rb')].each do |note|
  require note
end
  
class ActionController::Base
  # Note: these have to be defined as methods, not lambdas; lambdas don't have access to the logged_in_as_admin? helper
  prepend_before_filter :footnotes_before_if  
  def footnotes_before_if
    Footnotes::Filter.before self if Rails.env.development? or (logged_in? and current_user.has_role? 'admin') # Helper isn't accessible here
  end
  
  after_filter :footnotes_after_if  
  def footnotes_after_if
    Footnotes::Filter.after self if Rails.env.development? or (logged_in? and current_user.has_role? 'admin')
  end
end

# Make your own too:
module Footnotes
  module Notes
    class CurrentUserNote < AbstractNote
      # This method always receives a controller
      def initialize(controller)
        @current_user = controller.instance_variable_get("@current_user")
        super
      end

      # The name that will appear as legend in fieldsets
      def legend
        "Current user: #{@current_user.login} (#{@current_user.name})"
      end
 
      # This Note is only valid if we actually found an user
      # If it's not valid, it won't be displayed
      def valid? 
        @current_user
      end
      
      # The fieldset content
      def content
        escape(@current_user.inspect)
      end
      
      def title
        "Current user: #{@current_user.login}"
      end
    end
    
    class FirebugLiteNote < AbstractNote
      def has_fieldset?
        false
      end
      
      def title
        # This is just the Firebug Lite bookmarklet. Dynamically loads FBL, so we don't include it on page loads
        <<-'END'
          <a href="javascript:var firebug=document.createElement('script');firebug.setAttribute('src','http://getfirebug.com/releases/lite/1.2/firebug-lite-compressed.js');document.body.appendChild(firebug);(function(){if(window.firebug.version){firebug.init();}else{setTimeout(arguments.callee);}})();void(firebug);">Firebug Lite</a>
        END
      end
    end
    
    class SwfUploadNote < AbstractNote
      def title
        'SWFUpload'
      end
      
      def legend
        title
      end
      
      def content
        "<textarea id='SWFUpload_Console'></textarea>"
      end
    end
  end
end

Footnotes::Filter.notes += [:current_user, :swf_upload, :firebug_lite]
Footnotes::Filter.notes -= [:general]