*See `README.md` for general introduction and usage documentation.*

# Infrastructure

## Git repository

The source code of cocoda-db is managed in a public git repository at
<https://github.com/gbv/cocoda-db>.

The latest development is at the `dev` branch. The `master` branch is for
releases only!

## Issue tracker

Bug reports and feature requests are managed as GitHub issues at
<https://github.com/gbv/cocoda-db/issues>.

A Kanban board will be added later.

# Technology

Cocoda-db is currently written in Perl with Dancer as web framework and
Catmandu as data processing framework. The database backend is based on 
MongoDB. All of these choices are not carved in stone!

The application is build and released as Debian package for Ubuntu 14.04 LTS.

# Development

## First steps

For local usage and development clone the git repository and install
dependencies:

    sudo make dependencies
    make local

Locally run the web application on port 5000 for testing:

    make run

## Sources

Relevant source code is located in

* `lib/` - application sources (Perl modules)
* `debian/` - Debian package control files 
    * `changelog` - version number and changes 
      (use `dch` to update)
    * `control` - includes required Debian packages
    * `cocoda-db.default` - default config file 
      (only installed with first installation)
    * `install` - lists which files to install
* `cpanfile` - lists required Perl modules
* `app.psgi` - application main script

## Configuration

Configuration is loaded from `etc/config.yml` if this file exists or
`/etc/cocoda-db/config.yml` otherwise. A different file can be enforced with
environment variable `COCODA_DB_CONF`.

The configuration format should be restricted by JSON schema
`config-schema.yml` to early catch configuration file errors.

Config file `config.yml` is required by Dancer.

Config file `catmandu.yml` is required by Catmandu.

## Tests

Run all tests located in directory `t`. 

    make tests

To run a selected test, for instance `t/app.t`: 

    perl -Ilib -Ilocal/lib/perl5 t/app.t

## Continuous Integration

[![Build Status](https://travis-ci.org/gbv/cocoda.svg)](https://travis-ci.org/gbv/cocoda-db)

After pushing to GitHub tests are also run automatically twice 
[at travis-ci](https://travis-ci.org/gbv/cocoda-db). The first 
run is done via `make tests`, the second is run after packaging
against an instance installed at localhost.

## Packaging and Release

Create a Debian package

    make package

Make sure to run this on the target OS version (Ubuntu 14.04)!

Travis-ci is configured to release build packages on tagged 
versions.

# License

cocoda-db is made available under the terms of GNU Affero General Public
License (AGPL).

