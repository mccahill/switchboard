# Switchboard
On demand configuration of SDN network links for SDN controllers running the Ryu REST Router. 

Switchboard allows authorized users to create, approve and manage SDN connections between hosts and is currently used in production at Duke University, where we have begun deploying Software Defined Network (SDN) infrastructure for
on-demand configuration of bypass networks both on campus and between higher education institutions over Internet2. These SDN connections can provide very-high-speed paths for moving large volumes of data, and can be configured by on-the-fly Switchboard—a web application developed at Duke. 

Switchboard enables real-time, self-service provisioning of high-speed network links by authorized users; this simplifies setting up both long term networks and one-time connections for data migrations.

# Building Switchboard

To make this run a development version on your Mac:

- You should probably run Ruby 2.1.2.  Ruby Version Manager (RVM - see https://rvm.io) can be nice if you need to have multiple versions of Ruby on your system.

- check out this github project:
  git clone https://github.com/mccahill/switchboard.git

- run bundle
  bundle install

- set up the database
  rake db:setup
  rake db:migrate
  rake db:seed

- for development Switchboard is set to run as user 'liz'.  You can change this by editing line 11 in 
  app/controllers/application.rb    

  netid = 'liz'


- You are now ready to start your server:
  rails s  

- to run a rails console:
  rails c

We use Capistrano deploy the application. You will need to edit the capistrano configs to suit your situation.

- To deploy a staging instance, from within your Switchboard application directory type:
  cap staging deploy

- the production deployment command is: 
  cap production deploy

Two config files are are specific to your instance of Switchboard: 
  config/database.yml
  config/switchboard.yml

Examples of what these files should contain are found here:
  config/database_example.yml
  config/switchboard_example.yml

You should edit and rename these file to match what you have for database and SDN controller settings.

next: see the README-SDN-SETUP to configure an SDNHub setup so switchboard has something to talk to.
