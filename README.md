# Legend of Lod #

A text adventure mu* styled game, entirely for educational purposes.

At the center of the world a tower to the sky extends over
a long forgotten world of ruins.  Inhabited by strange creatures,
fragmented tribes of people and mysterious automations of a once
great civilization.  You find yourself traveling through the
desert and take refuge in a cave from one of the frequent sand
storms that cover and uncover ruins of the last civilization.

The goal of this short game is to reach the center of the world,
climb the tower of Lot and discover what's at the top.

## Installing ##

    $ rvm use 2.1.2
    $ gem install bundler
    $ bundle install

You must also run a migration to initialize the database.

## Migrations ##

    $ sequel -m db/migrations sqlite://db/lol.db

## Tests ##

    $ rake

## ssl ##

To generate a self-signed private certificate to use an encrypted server;

    $ openssl genrsa -out data/example_private.pem 1024
    $ openssl req -new -key data/example_private.pem -out data/example_request.csr
    $ openssl x509 -req -days 9999 -in data/example_request.csr -signkey data/example_private.pem -out data/example_signed_certifcate.pem

## Running ##

Start the server:

    $ ./lol.rb

Use the provided client, which will connect to localhost:9001 using ssl.

    $ ./client.rb

## License ##

MIT
