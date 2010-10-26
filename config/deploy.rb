set :application, "source_control"
set :deploy_to, "/var/www/"
set :repository, "git://github.com/krikis/source_control.git"

set :scm, :git
set :deploy_via, :remote_cache

set :user, "ubuntu"
ssh_options[:keys] = ["../../esposito.pem"]
set :use_sudo, true
set :appserver, "46.51.132.118"

role :web, appserver                          # Your HTTP server, Apache/etc
role :app, appserver                          # This may be the same as your `Web` server
role :db,  appserver, :primary => true # This is where Rails migrations will run

namespace :bundler do
  task :create_symlink, :roles => :app do
    shared_dir = File.join(shared_path, 'bundle')
    release_dir = File.join(current_release, '.bundle')
    run("mkdir -p #{shared_dir} && ln -s #{shared_dir} #{release_dir}")
  end
 
  task :bundle_new_release, :roles => :app do
    bundler.create_symlink
    run "cd #{release_path} && bundle install --without test"
  end
end
 
after 'deploy:update_code', 'bundler:bundle_new_release'

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
