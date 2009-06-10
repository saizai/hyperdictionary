#configuration = Capistrano::Configuration.respond_to?(:instance) ? Capistrano::Configuration.instance(:must_exist) : Capistrano.configuration(:must_exist)
#configuration.load do
  namespace :memcached do
    %w(start stop restart kill status).each do |cmd|
      desc "#{cmd} your memcached servers"
      task cmd.to_sym, :roles => :app do
        run "RAILS_ENV=production #{ruby} #{current_path}/script/memcached_ctl #{cmd}"
      end
    end
  end
#end
