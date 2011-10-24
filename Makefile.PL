use inc::Module::Install;

name     'SQLx-Core';
all_from 'lib/SQLx/Core.pm';
author   q{Brad Haywood <brad@geeksware.net>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

