package SQLx::Core::Result;

=head1 NAME

SQLx::Core::Result - Class for SQLx::Core results

=head1 DESCRIPTION

A single row is known as a Result. This module handles methods for them.

=cut 

use SQL::Abstract;
our $sql = SQL::Abstract->new;

use vars qw/$sql/;

our $VERSION = '0.09';

1;
