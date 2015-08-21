# Legend of Lod #

[![Build Status](https://travis-ci.org/ajduncan/lol.svg)](https://travis-ci.org/ajduncan/lol)

A text adventure mu* styled game, entirely for educational purposes.

At the center of the world a tower to the sky extends over
a long forgotten world of ruins.  Inhabited by strange creatures,
fragmented tribes of people and mysterious automations of a once
great civilization.  You find yourself traveling through the
desert and take refuge in a cave from one of the frequent sand
storms that cover and uncover ruins of the last civilization.

The goal of this short game is to reach the center of the world,
climb the tower of Lot and discover what's at the top.

## Running with Vagrant ##

If you want to run and develop locally, install [Chef-DK](https://downloads.chef.io/chef-dk/), which includes [Berkshelf](http://berkshelf.com/).

    $ vagrant plugin install vagrant-berkshelf
    $ berks install
    $ vagrant up

You should then be able to connect over localhost:9001.  Code changes should
cause rerun to restart the server.

If you want to tinker and have automatic code changes applied, you can also
kill the rerun process and use the following:

    $ vagrant ssh
    $ cd /vagrant

    $ /home/vagrant/.rbenv/versions/2.2.2/bin/rerun /home/vagrant/.rbenv/versions/2.2.2/bin/ruby /vagrant/lol.rb

    or

    $ rbenv exec gem install foreman
    $ rbenv exec foreman start


## Installing ##

    $ rvm use 2.2.2
    $ gem install bundler
    $ bundle install

You must also run a migration to initialize the database.

## Migrations ##

If using sqlite;

    $ sequel -m db/migrations sqlite://db/lol.db

Otherwise;

    $ sequel -m db/imgrations postgresql://user:pass@host/dbname

## Tests ##

    $ rake

## ssl ##

To generate a self-signed private certificate to use an encrypted server;

    $ openssl genrsa -out data/example_private.pem 1024
    $ openssl req -new -key data/example_private.pem -out data/example_request.csr
    $ openssl x509 -req -days 9999 -in data/example_request.csr -signkey data/example_private.pem -out data/example_signed_certifcate.pem

## Running ##

Start the server with defaults:

    $ ./lol.rb

You may run with environment variables such as:

    $ DB_URL=postgresql://lol:foobarbaz@localhost/lol HOST=0.0.0.0 ./lol.rb

Or copy the .env.example file to .env and edit the environment variables there,
depending on the security of your environment and what convention you're most
comfortable with.  Then the app will use these settings, or just use foreman:

    $ foreman start

Use the provided client, which will connect to localhost:9001 using ssl.

    $ ./client.rb

Authenticate using:

connect player1 foobarbaz

## License ##

lol is released under the [MIT License](https://raw.github.com/ajduncan/lol/master/LICENSE)
