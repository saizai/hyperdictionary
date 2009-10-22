# run with:  god -c /path/to/app.god

# Useful sources:
# http://rubypond.com/articles/2008/04/07/rails-god-config/
# http://rubypond.com/articles/2008/07/17/the-complete-guide-to-setting-up-starling/
# http://davedupre.com/2008/04/01/ruby-background-tasks-with-starling-part-3/
# http://www.thewebfellas.com/blog/2008/2/12/a-simple-faith-monitoring-by-god
# http://railscasts.com/episodes/130-monitoring-with-god

RAILS_ROOT = File.dirname(File.dirname(__FILE__))
RAILS_ENV = ENV['RAILS_ENV'] || 'development'
LOCAL_BIN = (RAILS_ENV == 'development' ? '/usr/bin' : "/usr/local/bin")
APP_NAME = 'Kura2'
MONGREL_PORTS = []
God.pid_file_directory = File.join(RAILS_ROOT, "tmp/pids/") # God will daemonize anything that doesn't have a pid_file specified, into this dir

God::Contacts::Email.message_settings = {
  :from => 'god@example.com'
}

God::Contacts::Email.server_settings = {
  :address => "smtp.example.com",
  :port => 25,
  :domain => "example.com",
  :authentication => :plain,
  :user_name => "john",
  :password => "s3kr3ts"
}

God.contact :email do |c|
  c.name = 'sai'
  c.email = 'kura2-god@saizai.com'
  c.group = 'developers'
end

def flapping w
  w.lifecycle do |on|
    on.condition :flapping do |c|
      c.notify = 'developers'
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end

def autostart w, interval = 5.seconds
  w.start_if do |start|
    start.condition :process_running do |c|
      c.interval = interval
      c.running = false
    end
  end
end

def resource_limits w, mem_limit, cpu_limit
  w.restart_if do |restart|
    restart.condition :memory_usage do |c|
      c.notify = 'developers'
      c.above = mem_limit
      c.times = [3, 5] # 3 out of 5 intervals
    end
  
    restart.condition :cpu_usage do |c|
      c.notify = 'developers'
      c.above = cpu_limit
      c.times = 5
    end
  end
end

God.watch do |w|
  w.name = "mysql"
  w.group = 'shared'
  w.interval = 30.seconds # default
  if RAILS_ENV == 'development'
    w.pid_file = '/usr/local/mysql/data/Sai-Xos.pid'
    w.start = "/usr/local/mysql/bin/mysqld_safe --datadir=/usr/local/mysql/data --pid-file=#{w.pid_file}"
    w.stop = "kill `cat #{w.pid_file}`"
  else
    w.pid_file = '/var/run/mysqld/mysqld.pid'
    w.start = "/etc/init.d/mysqld start" 
    w.stop = "/etc/init.d/mysqld stop" 
    w.restart = "/etc/init.d/mysqld restart" 
  end
  
  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.behavior :clean_pid_file

  autostart w
  flapping w
end

God.watch do |w|
  memcached_username = 'saizai'
  w.name = "memcached"
  w.group = 'shared'
  w.interval = 30.seconds
  w.pid_file = '/var/run/memcached.pid'
  w.start = "memcached -d -P #{w.pid_file} -u #{memcached_username}"
  w.stop = "kill `cat #{w.pid_file}`"
  w.start_grace = 30.seconds
  w.restart_grace = 30.seconds 
  w.behavior :clean_pid_file

  autostart w
  flapping w
end

unless RAILS_ENV == 'development'
  God.watch do |w|
    w.name = "#{APP_NAME}-apache"
    w.group = 'shared'
    w.interval = 30.seconds # default      
    w.start = "/etc/init.d/httpd start" 
    w.stop = "/etc/init.d/httpd stop" 
    w.restart = "/etc/init.d/httpd restart" 
    w.start_grace = 10.seconds
    w.restart_grace = 10.seconds
    w.pid_file = '/var/run/httpd.pid'
    w.behavior :clean_pid_file
  
    autostart w
    flapping w
  end
end

MONGREL_PORTS.each do |port|
  God.watch do |w|
    w.name = "#{APP_NAME}-mongrel-#{port}"
    w.group = APP_NAME
    w.interval = 30.seconds # default      
    w.pid_file = File.join(RAILS_ROOT, "tmp/pids/mongrel.#{port}.pid")
    w.start = "cd #{RAILS_ROOT}; #{LOCAL_BIN}/mongrel_rails start -e #{RAILS_ENV} -c #{RAILS_ROOT} -p #{port} -P #{w.pid_file}  -d"
    w.stop = "cd #{RAILS_ROOT}; #{LOCAL_BIN}/mongrel_rails stop -P #{w.pid_file}"
    w.restart = "cd #{RAILS_ROOT}; #{LOCAL_BIN}/mongrel_rails restart -P #{w.pid_file}"
    w.start_grace = 30.seconds
    w.restart_grace = 30.seconds
    w.behavior :clean_pid_file
    
    resource_limits w, 150.megabytes, 70.percent
    autostart w
    flapping w
  end
end