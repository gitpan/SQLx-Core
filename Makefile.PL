use inc::Module::Install;

name     'SQLx-Core';
all_from 'lib/SQLx/Core.pm';
author   q{Brad Haywood <brad@geeksware.net>};
license  'perl';

build_requires 'Test::More';
requires 'Module::Finder';
requires 'SQL::Abstract';
requires 'DBD::SQLite';
auto_install;

WriteAll;

