require 'fileutils'

plugin_root = File.dirname(__FILE__)

FileUtils.cp File.join(plugin_root, 'javascript', 'email_decoder.js'), File.join(RAILS_ROOT, 'public', 'javascripts')

puts IO.read(File.join(File.dirname(__FILE__), 'README'))

puts "\n\ncopied email_decoder.js into public/javascripts.  \n\n"