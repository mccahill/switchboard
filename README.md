# switchboard
On demand configuration of SDN network links for SDN controllers running the Ryu REST Router

Duke OIT has begun deploying Software Defined Network (SDN) infrastructure for
on-demand configuration of bypass networks both on campus and between higher education institutions over Internet2. These SDN connections can provide very-high-speed paths for moving large volumes of data, and can be configured by on-the-fly Switchboard—a web application developed at Duke. 

Switchboard enables real-time, self-service provisioning of high-speed network links by authorized users; this simplifies setting up both long term networks and one-time connections for data migrations.


== README

This is the Switchboard Rails application.  It provides a way to create, approve and manage SDN connections between hosts at Duke.

To make this run a development version on your Mac...
- You need Ruby 2.1.2.  RVM can be nice if you need to have multiple rubies on your system or you might want to use homebrew to install 1.9.3 and have ~/bin/ruby symlinked to it (and your PATH modified to use that)

- check out this gitorious project:
  git clone git@gitorious.oit.duke.edu:switchboard/switchboard.git

- run bundle
  bundle install

- set up the database
  rake db:setup
  rake db:migrate
  rake db:seed

- for Development it is set to run as user 'liz'.  You can change this in app/controllers/application.rb - edit line 11:    netid = 'liz'


- You are ready to start your server:
  rails s  

- to run a console,:
  rails c

We use Capistrano deploy the application

- To deplloy a staging instance, from within your Switchboard application directory type:
  cap staging deploy

- the production deployment command is: 
  cap production deploy

Two files are are specific to your instance of Switchboard: 
  config/database.yml
  config/switchboard.yml

Examples of what these files should contain are found here:
  config/database_example.yml
  config/switchboard_example.yml

You should edit and rename these file to match what you have for database and SDN con troller settings.

next: see the README-SDN-SETUP to configure an SDNHub setup so switchboard has something to talk to.
