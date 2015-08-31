# cocoda-db [![Build Status](https://travis-ci.org/gbv/cocoda.svg)](https://travis-ci.org/gbv/cocoda-db)

> Database service with JSKOS-API

## Installation

The software is released as Debian package and tested with Ubuntu 14.04 LTS. 

To install required dependencies either use a package manager such as `gdebi`,
manually install dependencies (inspectable via `dpkg -I cocoda_db_*.deb`), or
try to force installation of after failed install:

    sudo dpkg -i cocoda-db_X.Y.Z_amd64.deb   # change X.Y.Z to version
    sudo apt-get -f install

## Usage

### JSKOS-API

After installation a public [JSKOS API](https://gbv.github.io/jskos-api/) is
available at localhost on port 6033. The current implementation does not fully
conform a selected version of JSKOS API specification yet.

The `/mappings` endpoint at <http://127.0.0.1/mappings> can be queried with the
following query parameters:

* `fromScheme` and `toScheme` to select concept schemes by URI
* `fromSchemeNotation` and `toSchemeNotation` to select concept schemes
  by Notation
* `from` and `to` to select concepts by URI
* `fromNotation` and `toNotation` to select concepts by notations
* `creator`, `publisher`, `contributor`, `source`, `provenance`
* `dateAccepted`, `dateModified`
 
The following general query parameters are supported as well:

* `limit`
* `page`
* `unique`

JSONP and CORS is also implemented.

### Importing and exporting JSKOS

Right now JSKOS data can only be imported at the server via command line. Log
in to base directory (`/srv/cocoda-db` after installation) and execute:

    ./catmandu import JSKOS to mappings < file.json
    ./catmandu export mappings to JSKOS > file.json

Note that JSKOS data is not validated or checked for completeness and
duplicates!

## Administration

### Logging

Log files are written in `/var/log/cocoda-db/` and kept for 30 day by default:

* `access.log` - HTTP request and responses in Apache Log Format
* `server.log` - Web server messages (when server was started and stopped)
* `deployment.log` - Error messages, warnings, and runtime information

Each entry in `deployment.log` starts with the following values

* day
* time
* seconds since request
* IP address of the remote host
* log message

Log messages may span multiple lines.

## License

cocoda-db is made available under the terms of GNU Affero General Public
License (AGPL).

## Development

The software is managed in a public git repository at
<https://github.com/gbv/cocoda-db>. 

Please report bugs and feature request in the public issue tracker!

For local usage and development clone the git repository and install
dependencies:

    sudo make dependencies
    make local

Locally run the web application on port 5000 for testing:

    make run

### Database

The internal database `cocoda` can be inspected and modified with any MongoDB
client, for instance the command line client `mongo`:

    $ mongo cocoda
    > ...
    > db.mappings.drop()

Access restrictions may be added in a later version to avoid accidently
damaging the database.

### Tests

Run all tests located in directory `t`. 

    make tests

To run a selected test, for instance `t/app.t`: 

    PLACK_ENV=tests perl -Ilib -Ilocal/lib/perl5 t/app.t

Tests are also run automatically for continuous integration
[at travis-ci](https://travis-ci.org/gbv/cocoda-db) after push to GitHub.

### Packaging and Release

Create a Debian package

    make package

