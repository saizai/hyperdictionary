# No need for mongrel cluster if using Phusion Passenger
# require 'mongrel_cluster/recipes'
load 'lib/super_deploy.rb'

set :scm, :git

# application name - i.e. /apps/#{application} - required
set :application, "kura2"  
# deploy_to must be path from root
set :deploy_to, "/home/kura2/dictionary.conlang.org/" # defaults to "/u/apps/#{application}"
# set :mongrel_conf, "#{deploy_to}/current/config/mongrel_cluster.yml"
set :user, "kura2"
set :runner, "kura2"
set :use_sudo, false

ssh_options[:keys] = %w(~/.ssh/kura_deploy)

# This is needed on Joyent's Sun OS to ensure that the password prompts work correctly
# See http://groups.google.com/group/capistrano/browse_thread/thread/13b029f75b61c09d
# default_run_options[:pty] = true 

# URL of repository required
#set :ip, '##.##.##.##'

set :repository, "git://github.com/saizai/hyperdictionary.git"

# :no_release => true means that no code will be deployed to that box
# :primary => true is currently unused, but could eg be for primary vs slave db servers
# you can have multiple "role :foo, "serverip", :options=>whatnot" lines, or server "ip", :role, :role2, :role3, :options=>foo
#server "#{ip}", :app, :db, :web, :primary => true
#role :app, "your app-server here"
#role :web, "your web-server here"
#role :db,  "your db-server here", :primary => true

server 'dictionary.conlang.org', :app, :web, :primary => true # We have no access to DB server directly

namespace (:deploy) do
  desc "Restart using Passenger" 
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  
#  after "deploy:setup", "deploy:god:restart" 
#  namespace :god do
#    task :restart, :roles=>:app do
#      sudo "/usr/bin/god restart #{application}"
#    end
#    
#    task :status, :roles => :app do
#      sudo "/usr/bin/god status"
#    end
#  end
#
#  [ :stop, :start, :restart ].each do |t|
#    desc "#{t.to_s.capitalize} app using god"
#    task t, :roles => :app do
#      sudo "god #{t.to_s} #{application}"
#    end
#  end

  after "deploy:update_code", "deploy:set_permissions"
  
  desc "Ensure app's permissions are set correctly."
  task :set_permissions, :except => { :no_release => true } do         
    # For all files in the shared config path
    Dir[File.join(shared_path, 'config', '**', '*.rb')].each do |c|
      run "rm #{c}" # Remove the deployed version
      run "ln -s #{c} #{release_path}/config/#{c[/[^\/]*$/]}" # And symlink in the server's version
    end

#    run "cp #{deploy_to}/shared/config/mongrel_cluster.yml #{release_path}/config"
#    run "chmod 775 #{release_path}/config/mongrel_cluster.yml"
#    
#    run "rm -f #{release_path}/config/dblogin.yml"
#    
#    run "rm -rf #{release_path}/data"
#    run "ln -nfs #{shared_path}/data #{release_path}/data"  
  end

#  task :set_permissions_staging, :except => { :no_release => true } do 
#      run "rm -f #{release_path}/config/database.yml"
#      run "cp #{deploy_to}/shared/config/database.yml #{release_path}/config"
#      run "chmod 775 #{release_path}/config/database.yml"
#  end  
end

#namespace :starling do
#  [ :stop, :start, :restart ].each do |t|
#    desc "#{t.to_s.capitalize} starling using god"
#    task t, :roles => :app do
#      sudo "god #{t.to_s} starling"
#    end
#  end
#end
#
#namespace :workling do
#  [ :stop, :start, :restart ].each do |t|
#    desc "#{t.to_s.capitalize} workling using god"
#    task t, :roles => :app do
#      sudo "god #{t.to_s} #{application}-workling"
#    end
#  end
#end


# =============================================================================
# OPTIONAL VARIABLES
# =============================================================================

# set :scm, :darcs               # defaults to :subversion
# set :svn, "/path/to/svn"       # defaults to searching the PATH
# set :darcs, "/path/to/darcs"   # defaults to searching the PATH
# set :cvs, "/path/to/cvs"       # defaults to searching the PATH
# set :gateway, "gate.host.com"  # default to no gateway

# =============================================================================
# SSH OPTIONS
# =============================================================================
# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25
