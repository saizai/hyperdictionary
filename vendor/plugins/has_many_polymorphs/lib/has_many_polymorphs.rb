
require 'active_record'

Rails.logger = nil unless defined? Rails.logger

require 'has_many_polymorphs/reflection'
require 'has_many_polymorphs/association'
require 'has_many_polymorphs/class_methods'

require 'has_many_polymorphs/support_methods'
require 'has_many_polymorphs/base'

class ActiveRecord::Base
  extend ActiveRecord::Associations::PolymorphicClassMethods 
end

if ENV['HMP_DEBUG'] || ENV['Rails.env'] =~ /development|test/ && ENV['USER'] == 'eweaver'
  require 'has_many_polymorphs/debugging_tools' 
end

if defined? Rails and Rails.env and Rails.root
  _logger_warn "rails environment detected"
  require 'has_many_polymorphs/configuration'
  require 'has_many_polymorphs/autoload'
end

_logger_debug "loaded ok"
