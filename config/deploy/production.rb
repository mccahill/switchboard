server 'sdn-sb-prod-01.oit.duke.edu', :app, :web, :db, :primary => true

set :rails_env, 'production'
set :deploy_via, :export

set :vhost, 'switchboard.oit.duke.edu'

