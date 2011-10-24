#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'SQLx::Core' ) || print "Bail out!\n";
}

diag( "Testing SQLx::Core $SQLx::Core::VERSION, Perl $], $^X" );
