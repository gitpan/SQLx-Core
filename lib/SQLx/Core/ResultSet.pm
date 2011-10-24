package SQLx::Core::ResultSet;

=head1 NAME

SQLx::Core::ResultSet - Methods for searching and altering tables

=cut

use SQL::Abstract;

our $sql = SQL::Abstract->new;
use vars qw/$sql/;

our $VERSION = '0.02';

=head2 count

Returns the number of rows found

=cut

sub count {
    my $self = shift;

    return scalar @{$self->{result}};
}

=head2 first

Get the first result from a resultset

=cut

sub first {
    my $self = shift;

    return bless $self->{result}->[0], $self->{r};
}

=head2 next

A simple iterator to loop through a resultset. Each 
returned result will be blessed as a Result.

    # MySchema/Result/Table.pm

    sub name { return shift->{result}->{name}; }

    # test.pl

    while(my $row = $result->next) {
        print $row->name;
    }

=cut

sub next {
    my $self = shift;
    if (! exists $self->{_it_pos}) {
        $self->{_it_pos} = 0;
        $self->{_it_max} = scalar @{$self->{result}};
    }
    my $pos = $self->{_it_pos};
    $self->{_it_pos}++;
    if ($self->{_it_pos} > $self->{_it_max}) {
        delete $self->{_it_pos};
        delete $self->{_it_max};
        return undef;
    }
    my $rs = {
        dbh    => $self->{dbh},
        result => $self->{result}->[$pos], 
        table  => $self->{table},
        primary_key => $self->{primary_key},
        r => $self->{r},
        rs => $self->{rs},
    };
    #return $self->{result}->[$pos];
    return bless $rs, $self->{r};
}

=head2 primary_key

Sets the primary key for the current ResultSet

    $rs->primary_key('id');

=cut

sub primary_key {
    my ($self, $key) = @_;

    return 0 if ! $key;
    
    $self->{primary_key} = $key;
    return 1;
}

=head2 search

Access to the SQL SELECT query. Returns an array with the selected rows, which contains a hashref of values.
First parameter is an array of what you want returned ie: SELECT this, that
If you enter an empty array ([]), then it will return everything ie: SELECT *
The second parameter is a hash of keys and values of what to search for.

    my $res = $resultset->search([qw/name id status/], { status => 'active' });

    my $res = $resultset->search([], { status => 'disabled' });
    
    my $res = $resultset->search([], { -or => [ name => 'Test', name => 'Foo' ], status => 'active' });

=cut

sub search {
    my ($self, $fields, $c) = @_;
    if (scalar @$fields == 0) { push @$fields, '*'; }
    if (exists $self->{where}) {
        for (keys %{$self->{where}}) {
            $c->{$_} = $self->{where}->{$_};
        }
    }
        
    my ($stmt, @bind) = $sql->select($self->{table}, $fields, $c);
    my ($wstmt, @wbind) = $sql->where($c);
        
    my $result = {
        dbh    => $self->{dbh},
        result => $self->{dbh}->selectall_arrayref($stmt, { Slice => {} }, @bind),
        stmt   => $wstmt,
        bind   => \@wbind,
        where  => $c,
        table  => $self->{table},
        primary_key => $self->{primary_key},
        r           => $self->{r},
        rs          => $self->{rs},
    };
    return bless $result, $self->{rs};
    #return $result;
}

sub find {
    my ($self, $fields, $c) = @_;
    if (scalar @$fields == 0) { push @$fields, '*'; }
    my ($stmt, @bind) = $sql->select($self->{table}, $fields, $c);
    my ($wstmt, @wbind) = $sql->where($c);
    my $r = {
        dbh    => $self->{dbh},
        result => $self->{dbh}->selectall_arrayref($stmt, { Slice => {} }, @bind)->[0],
        stmt   => $wstmt,
        bind   => \@wbind,
        #where  => $sql->generate('where', $c),
        where  => $c,
        table  => $self->{table},
        primary_key => $self->{primary_key},
        r       => $self->{r},
        rs      => $self->{rs},
    };

    return bless $r, $self->{r};
}

=head2 insert

Inserts a new record into the current resultset.

    my $insert = $resultset->insert({name => 'Foo', user => 'foo_bar', pass => 'baz'});
    if ($insert) { print "Added user!\n"; }
    else { print "Could not add user\n"; }

=cut

sub insert {
    my ($self, $c) = @_;
    
    my ($stmt, @bind) = $sql->insert($self->{table}, $c);
    my $sth = $self->{dbh}->prepare($stmt);
    my $result = $sth->execute(@bind);

    # make sure it succeeded
    my $res = $self->search([], $c);
#    $result =  $self->{dbh}->selectall_arrayref($sql->select($self->{table}, [], $c), { Slice => {} }, @bind);
    ($stmt, @bind) = $sql->select($self->{table}, ['*'], $c);
    
    if ($res->count) {
        my $rs = {
            dbh    => $self->{dbh},
            where  => $c,
            table  => $self->{table},
            result => $self->{dbh}->selectall_arrayref($stmt, { Slice => {} }, @bind),
            primary_key => $self->{primary_key},
            r       => $self->{r},
            rs      => $self->{rs},
        };
        
        return bless $rs, 'SQLx::Core::Result';
    }
    else { return 0; }    
}

1;
