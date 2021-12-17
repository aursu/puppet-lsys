# Changelog

All notable changes to this project will be documented in this file.

## Release 0.5.4

**Features**

* Added Nginx map directory to store snippets to include inside map directives'
  blocks

**Bugfixes**

**Known Issues**

## Release 0.6.0

**Features**

* Added cron daemon management

**Bugfixes**

**Known Issues**

## Release 0.6.1

**Features**

* Added Monit installation into module

**Bugfixes**

**Known Issues**

## Release 0.6.2

**Features**

* Added Monit and systemd settings for cron

**Bugfixes**

**Known Issues**

## Release 0.6.3

**Features**

* Added lockrun installation
* Added libconfig installation

**Bugfixes**

**Known Issues**

## Release 0.6.4

**Features**

* Added logrotate management

**Bugfixes**

**Known Issues**

## Release 0.6.5

**Features**

* Added ntpdate management

**Bugfixes**

**Known Issues**

## Release 0.6.6

**Features**

* Added /etc/login.defs hardening

**Bugfixes**

* Replaced dockerinstall class definition with include

**Known Issues**

## Release 0.7.0

**Features**

* Added class lsys::resolv
* Added function lsys::fqdn_rand_array

**Bugfixes**

* Moved Java connfiguration types into javalocal module
* Renamed some types following Stdlib approach

**Known Issues**

## Release 0.7.1

**Features**

**Bugfixes**

* Replace Socket.gethostname with Facter.value(:hostname)

**Known Issues**

## Release 0.8.0

**Features**

* Added lsys::bindmount defined type

**Bugfixes**

**Known Issues**

## Release 0.9.0

**Features**

* Added lsys::tools::system with sudo

**Bugfixes**

**Known Issues**

## Release 0.10.0

**Features**

* Added lsys::tools::* set of classes with different system tools
* Switched to lsys::tools::package and Lsys::PackageVersion type use

**Bugfixes**

**Known Issues**

## Release 0.11.0

**Features**

* Added ability to harden crontab usage to specified users

**Bugfixes**

**Known Issues**

## Release 0.12.0

**Features**

* Added GCC into lsys::tools::lang

**Bugfixes**

**Known Issues**

## Release 0.13.0

**Features**

* Added /etc/profile management

**Bugfixes**

**Known Issues**

## Release 0.14.0

**Features**

* Added sysstat tool installation and logs hardening

**Bugfixes**

**Known Issues**

## Release 0.15.0

**Features**

* Added file system hardening

**Bugfixes**

**Known Issues**

## Release 0.16.0

**Features**

* Added packages cleanup
* Added PHP 8 bintray repo definition

**Bugfixes**

**Known Issues**

## Release 0.17.0

**Features**

* Added ability to disable tcp_wrappers

**Bugfixes**

**Known Issues**

## Release 0.18.0

**Features**

* Added CentOS 8 PowerTools repository

**Bugfixes**

**Known Issues**

## Release 0.19.0

**Features**

* Allow to setup different owner/group while quota package hardening

**Bugfixes**

**Known Issues**

## Release 0.19.1

**Features**

* Allow to provide mail relay into postfix configuration

**Bugfixes**

**Known Issues**

## Release 0.19.2

**Features**

* Added puppet installation profile

**Bugfixes**

**Known Issues**

## Release 0.19.3

**Features**

**Bugfixes**

* Added ability to use lsys::postgres with puppetlabs/postgres < 7.0.0

**Known Issues**

## Release 0.20.0

**Features**

* Added Google Chrome installation

**Bugfixes**

**Known Issues**

## Release 0.20.1

**Features**

* Added man tools installation

**Bugfixes**

**Known Issues**

## Release 0.21.0

**Features**

* Added NodeJS installation
* Added Google Lighthous installation

**Bugfixes**

**Known Issues**

## Release 0.21.1

**Features**

**Bugfixes**

* Corrected bintray location

**Known Issues**

## Release 0.21.2

**Features**

* Added Rsyslog upstream  repository

**Bugfixes**

**Known Issues**

## Release 0.22.0

**Features**

**Bugfixes**

* Added Class[Lsys::Repo] into lsys::repo::rsyslog
* Fixed CentOS Stream flag setup in lsys::params for Puppet 5 and 6

**Known Issues**

## Release 0.23.0

**Features**

**Bugfixes**

* Updated module dependencies

**Known Issues**

## Release 0.24.0

**Features**

* Added compiler Puppet server operational mode
* Added common environment in use into puppet.conf
* Added ability to disable PuppetDB

**Bugfixes**

**Known Issues**

## Release 0.24.1

**Features**

**Bugfixes**

* Removed `compiler` flag

**Known Issues**

## Release 0.24.2

**Features**

* Added ability to install packages out of corporate repo

**Bugfixes**

**Known Issues**