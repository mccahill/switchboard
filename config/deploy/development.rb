server 'sdn-sb-dev-01.oit.duke.edu', :app, :web, :db, :primary => true
set :vhost, 'switchboard-dev.oit.duke.edu'

set :rails_env, 'development'

# Deploy from local working copy
set :repository, "."
set :scm, :none
set :deploy_via, :copy
set :copy_exclude, [".git/*", 'config/database.yml', 'config/switchboard.yml']

set :keep_releases, 25


