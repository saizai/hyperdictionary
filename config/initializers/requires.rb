require 'redcloth'
 
(Dir[File.join(Rails.root, 'lib', 'extensions', '*.rb')] +
 Dir[File.join(Rails.root, 'lib', '*.rb')]).each do |f|
  require f unless f =~ /super_deploy/	
end
