require 'bundler/capistrano'

set :user, 'www-data'
set :domain, 'link-and-sync.com'
set :applicationdir, '/opt/linknsync'

set :application, "Link And Sync"
set :repository,  "ssh://git@github.com:murphybytes/linknsynch.git"
set :scm, :git
set :branch, 'master'
set :deploy_to applicationdir
set :deploy_via, :export


role :web, domain                          # Your HTTP server, Apache/etc
role :app, domain                          # This may be the same as your `Web` server
role :db,  domain, :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true
ssh_options[:keys] = ["#{ENV['HOME']}/awskeys/linuxdevbox.pem"]

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end 
end
