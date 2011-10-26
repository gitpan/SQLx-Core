#!perl -T

use Test::Most;
use FindBin;
use lib "t";

BEGIN {
    use_ok('SQLx::Test::Schema', 'Got Test Schema OK');
}

my $rs = SQLx::Test::Schema->connect(
    dbi => 'SQLite:t/db/test.db',
)->resultset('Foo');

$rs->primary_key('id');
$rs->insert({name => 'Foo Master', status => 'active'});

my $search = $rs->search([], { name => 'Foo Master' });

is($search->count, 1, 'Insert and Select a record');
is($search->first->name, 'Foo Master', 'Check custom accessors and Result methods work');

$search->delete;

done_testing;
