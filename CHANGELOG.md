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

## Release 0.24.3

**Features**

* Make ability to disable tools for remote access management

**Bugfixes**

**Known Issues**

## Release 0.25.0

**Features**

* PDK upgrade

**Bugfixes**

**Known Issues**

## Release 0.25.1

**Features**

* Added Ubuntu support for Nginx packages installation

**Bugfixes**

**Known Issues**

## Release 0.25.3

**Features**

* Added Postgres 12.9 for CentOS Stream 8

**Bugfixes**

* Disable package repo management for CentOS Stream 8

**Known Issues**

## Release 0.25.5

**Features**

* Added CVE-2021-4034 mitigation

**Bugfixes**

**Known Issues**

## Release 0.26.0

**Features**

**Bugfixes**

* Added dependencies on Class level to make compatibility with
  postgresql module v6+

**Known Issues**

## Release 0.27.0

**Features**

* Added non-RedHat support for Python management

**Bugfixes**

**Known Issues**

## Release 0.28.0

**Features**

* Added ability to use multiple corporate repos for package installation
* Added ability to use corporate repos exclusively

**Bugfixes**

**Known Issues**

## Release 0.28.1

**Features**

**Bugfixes**

* Added PostgreSQL version 13.8, 14 and 15

**Known Issues**

## Release 0.28.2

**Features**

**Bugfixes**

* Set Nginx default version to 1.23.1

**Known Issues**

## Release 0.28.3

**Features**

**Bugfixes**

* Added latest PostgreSQL versions for 10, 11 and 12

**Known Issues**

## Release 0.28.4

**Features**

**Bugfixes**

* Added postfix user/group management for RedHat

**Known Issues**

## Release 0.29.0

**Features**

* Added NodeJS versions 18.x, 19.x and 20.x
* Monit version is 5.32.0

**Bugfixes**

* Removed PHP  8.0 and PHP 7.3 support from bintray repos

**Known Issues**

## Release 0.29.1

**Features**

* PDK upgrade to 2.5.0

**Bugfixes**

**Known Issues**

## Release 0.29.4

**Features**

* Added ability to specify custom ENC repo name

**Bugfixes**

**Known Issues**

## Release 0.29.5

**Features**

* Added file resource for Epel repo
  in case if /etc/yum.repos.d directory has parameter purge

**Bugfixes**

**Known Issues**

## Release 0.29.6

**Features**

* Set default postgresql version to 12.13

**Bugfixes**

**Known Issues**

## Release 0.29.7

**Features**

* Added Docker TLS user access flag

**Bugfixes**

**Known Issues**

## Release 0.29.8

**Features**

* Added util-linux package to be installed (with flock tool)
  instead of custom lockrun tool

**Bugfixes**

**Known Issues**

## Release 0.29.9

**Features**

* Added r10k crontab into puppet::lsys

**Bugfixes**

**Known Issues**

## Release 0.30.0

**Features**

* Added Rocky Linux 8

**Bugfixes**

**Known Issues**

## Release 0.30.1

**Features**

* Added PuppetDB server name parameter into lsys::puppet

**Bugfixes**

**Known Issues**

## Release 0.31.0

**Features**

* Added netcat package into tools
* Added unit test for webserver.conf management
* Added permissions set for Postfix runtime directories

**Bugfixes**

**Known Issues**

## Release 0.32.0

**Features**

* Added Rocky Linux 8 custom Postfix master.cf config
* Added ability to setup maillog_file parameter into Postfix main.cf

**Bugfixes**

**Known Issues**

## Release 0.33.0

**Features**

* PDK upgrade
* Default logrotate settings
* Updated PostrgeSQL allowed versions to latest on this day (removed EOL)

**Bugfixes**

**Known Issues**

## Release 0.34.0

**Features**

* Added postfix client settings for Ubuntu

**Bugfixes**

* Fixed unit tests for Ubuntu 20.04

**Known Issues**

* lsys::monit is not compatible with Ubuntu 20.04+ due to dependent module

## Release 0.35.0

**Features**

* Added Ubuntu specific logrotate.conf configuration

**Bugfixes**

* Fixed unit test for lsys::ntpdate

**Known Issues**

## Release 0.36.0

**Features**

* Added default value for logrotate su directive on Ubuntu

**Bugfixes**

**Known Issues**

## Release 0.37.0

**Features**

* Added ability to merge logrotate rule with global rules

**Bugfixes**

**Known Issues**

## Release 0.38.0

**Features**

* Upgraded PostgreSQL to version 15
* Updated PostrgeSQL allowed versions to latest on this day

**Bugfixes**

* Improved Ubuntu support

**Known Issues**

## Release 0.39.0

**Features**

* Added functionality to setup TLS assets on Web service

**Bugfixes**

**Known Issues**

## Release 0.40.0

**Features**

* Added client certificates verification

**Bugfixes**

**Known Issues**