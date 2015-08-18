# cocoda-db

This repository contains a database backend for Colibri Concordance Database. 
See also <https://github.com/gbv/cocoda> for a web client.

## Installation

The software is released as Debian package and tested with Ubuntu 14.04 LTS.

To install required dependencies either use a package manager such as `gdebi`
or force installation of missing dependencies after installation with
`apt-get`:

    sudo dpkg -i cocoda-db_1.2.3_amd64.deb
    sudo apt-get -f install

## Usage

### JSKOS-API

fter installation a public [JSKOS API](https://github.com/gbv/jskos-api) is
available at localhost on port 6033. The current version only supports a
`/mappings` endpoint at <http://127.0.0.1/mappings> with the following query
parameters:

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

JSONP is also implemented.

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

## Tests

Run `make tests` to run unit tests located in directory `t`.

