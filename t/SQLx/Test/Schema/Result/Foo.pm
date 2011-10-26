package SQLx::Test::Schema::Result::Foo;

use base 'SQLx::Core';

sub id { return shift->{id}; }
sub name { return shift->{name}; }

1;
