package SQLx::Core::Result;

=head1 NAME

SQLx::Core::Result - Class for SQLx::Core results

=head1 DESCRIPTION

A single row is known as a Result. This module handles methods for them.

=cut 

use SQL::Abstract;
our $sql = SQL::Abstract->new;

use vars qw/$sql/;

our $VERSION = '0.03';

=head2 result

Returns the result arrayref.

    for my $row (@{$res->result}) {
        print $row->{mykey} . "\n";
    }

=cut

sub result {
    my ($self, $key) = @_;
    if ($key) { return $self->{result}->[0]->{$key}||0; }
    return $self->{result}||0;
}

=head2 insert_id

Gets the primary key value of the last inserted row. It will require the primary key to be set, though

=cut

sub insert_id {
    my ($self) = @_;
    
    if (! exists $self->{primary_key}) {
        warn "Can't call insert_id on result when no primary_key was defined in the ResultSet";
        return 0;
    }
    if (exists $self->{result}->[scalar(@{$self->{result}})-1]->{$self->{primary_key}}) { 
        return $self->{result}->[scalar(@{$self->{result}})-1]->{$self->{primary_key}};
    }
    
    return 0;
}

=head2 update

Updates the current result using the hash specified

    my $res = $dbh->resultset('foo_table')->search([], { id => 5132 });
    if ($res->update({name => 'New Name'})) {
        print "Updated!\n";
    }

=cut

sub update {
    my ($self, $fieldvals) = @_;

    my ($stmt, @bind) = $sql->update($self->{table}, $fieldvals, $self->{where});
    my $sth = $self->{dbh}->prepare($stmt);
    if ($sth->execute(@bind)) { return 1; }
    else { return 0; }
}

=head2 delete

Drops the records in the current search result

    my $res = $resultset->search([], { id => 2 });
    $res->delete; # gone!

=cut

sub delete {
    my ($self) = @_;

    my ($stmt, @bind) = $sql->delete($self->{table}, $self->{where});

    my $sth = $self->{dbh}->prepare($stmt);
    $sth->execute(@bind);
}

1;
