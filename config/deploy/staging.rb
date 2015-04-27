server 'switchboard-web-test-01.oit.duke.edu', :app, :web, :db, :primary => true
set :vhost, 'switchboard-web-test.oit.duke.edu'

set :rails_env, 'test'
set :branch, 'staging'

