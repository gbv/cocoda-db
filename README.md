# NAME

cocoda-db - Database service implementing JSKOS-API

[![Build Status](https://travis-ci.org/gbv/cocoda-db.svg?branch=master)](https://travis-ci.org/gbv/cocoda-db)
[![Latest Release](https://img.shields.io/github/release/gbv/cocoda-db.svg)](https://github.com/gbv/cocoda-db/releases)

# SYNOPSIS

The application is automatically started as service, listening on port 6033

    sudo service cocoda-db {status|start|stop|restart}

# DESCRITPION

cocoda-db provides a [JSKOS API](https://gbv.github.io/jskos-api/) webservice.
The current implementation partly implements JSKOS API specification 0.1.0.

# INSTALLATION

The software is released as Debian package for Ubuntu 14.04 LTS. Other Debian
based distributions *might* work too. Releases can be found at
<https://github.com/gbv/gndaccess/releases>

To install required dependencies either use a package manager such as `gdebi`,
manually install dependencies (inspectable via `dpkg -I cocoda_db_*.deb`), or
try to force installation of after failed install:

    sudo dpkg -i ...                         # install dependencies
    sudo dpkg -i cocoda-db_X.Y.Z_amd64.deb   # change X.Y.Z
    sudo apt-get -f install                  # repair

After installation the service is available at localhost on port 6033. 

# ADMINISTRATION

## Importing and exporting JSKOS

Right now JSKOS data can only be imported at the server via command line. Log
in to base directory (`/srv/cocoda-db` after installation) and execute:

    ./catmandu import JSKOS to mappings < file.json
    ./catmandu export mappings to JSKOS > file.json

Note that JSKOS data is not validated or checked for completeness and
duplicates!

## Logging

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

## Database

The internal database `cocoda` can be inspected and modified with any MongoDB
client, for instance the command line client `mongo`:

    $ mongo cocoda
    > ...
    > db.mappings.drop()

Access restrictions may be added in a later version to avoid accidently
damaging the database.

## Configuration

Config file `/etc/default/cocoda-db` only contains basic server configuration
in form of simple key-values pairs:

* `PORT`    - port number (required, 6033 by default)

* `WORKERS` - number of parallel connections (required, 5 by default).

# SEE ALSO

The source code of cocoda-db is managed in a public git repository at
<https://github.com/gbv/cocoda-db>. Please report bugs and feature request at
<https://github.com/gbv/cocoda-db/issues>!

The Changelog is located in file `debian/changelog`.

Development guidelines are given in file `CONTRIBUTING.md`.

