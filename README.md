# cocoda-db [![Build Status](https://travis-ci.org/gbv/cocoda.svg?branch=master)](https://travis-ci.org/gbv/cocoda-db)

This repository contains a database backend for Colibri Concordance Database. 
See also <https://github.com/gbv/cocoda> for a web client.

## Installation

    sudo apt-get install couchdb
    curl -X PUT localhost:5984/mapping

## Development

Clone the repository from <https://github.com/gbv/cocoda-db>.
The software is managed in a public git repository at
<https://github.com/gbv/cocoda-db>. 

Please report bugs and feature request in the public issue tracker!

For local usage and development clone the git repository and install
dependencies:

    sudo make dependencies
    make local

To run the web application locally on port 5000:
 
    make run

### Database

The internal database `cocoda` can be inspected and modified with any MongoDB
client, for instance the command line client `mongo`:

    $ mongo cocoda
    > ...
    > db.mappings.drop()

Access restrictions may be added in a later version to avoid accidently
damaging the database.

## Tests

Run `make tests` to run unit tests localted in directory `t`.

