# Initial deploy:
# cap staging deploy:cold
# cap staging deploy:seed

# Updates:
# cap staging deploy


# setup multi-stage
set :stages, %w(production staging development)
set :default_stage, "development"
require 'capistrano/ext/multistage'
require 'bundler/capistrano'


# App specific configs
set :rubyver, '1.9.3'
set :application, "switchboard"
set :keep_releases, 5
set :repository,  "git@gitorious.oit.duke.edu:switchboard/switchboard.git"
set :scm, :git

# General configs - these are mostly the same across projects
load 'deploy/assets'
set :branch, 'master'
set :user, 'capdeploy'
set :runtime_group, 'apache'
set :scm_verbose, true
set :deploy_via, :remote_cache
set :use_sudo, false
# Lets try to keep sane security
set :group_writable, false
# Don't give errors about javascript and stylesheets directories
set :public_children, %w(images)
default_run_options[:pty] = true  # Must be set for the host key prompt
                                  # from git to work

set(:deploy_to) { "/srv/web/#{vhost}/rails/#{application}_#{rails_env}" }


set :default_environment, {
  :LANG => 'en_US.UTF-8',
  :PATH => "/opt/ruby-#{rubyver}/bin:$PATH",
}

# Munge the stages

before 'deploy:cold', 'deploy:setup'
after 'deploy:restart', 'deploy:cleanup'
#after 'deploy:cold', 'deploy:seed'
after 'deploy:finalize_update', 'deploy:htaccess'
after 'deploy:finalize_update', 'deploy:symlink_configs'
after 'deploy:finalize_update', 'deploy:symlink_locks'
before 'deploy:create_symlink', 'deploy:perms'

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  desc 'reload the database with seed data'
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  task :perms, :roles => :app do
    run "touch #{shared_path}/log/#{rails_env}.log"
    run "touch #{shared_path}/log/resource.log"
    run "chmod g+w #{shared_path}/pids"
    run "chmod -Rf g+w #{shared_path}/log"
    run "chmod -Rf g+w #{release_path}/tmp"
  end
  task :htaccess, :roles => :app do
    put "RackEnv #{rails_env}\nPassengerRuby /opt/ruby-#{rubyver}/bin/ruby\n", "#{release_path}/public/.htaccess"
  end
  task :symlink_configs, :roles => :app do
    run "ln -s /etc/#{application}.yml #{release_path}/config/#{application}.yml"
    run "ln -s /etc/#{application}-database.yml #{release_path}/config/database.yml"
  end
  task :symlink_locks, :roles => :app do
    run "mkdir -p #{shared_path}/locks"
    run "chmod g+w #{shared_path}/locks"
    run "ln -s #{shared_path}/locks #{release_path}/tmp/locks"
  end
end
namespace :tail do
  task :resource do
    run "tail -f #{shared_path}/log/resource.log"
  end
  task :web do
    run "tail -f #{shared_path}/log/#{rails_env}.log"
  end
end
