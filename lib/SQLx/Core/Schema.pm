package SQLx::Core::Schema;
#use base 'SQLx::Lite::ResultSet';

sub resultset {
    my ($self, $table) = @_;

    my $pkg = "$self->{schema}::ResultSet::$table";
    $self->{resultset} = { dbh => $self->{dbh}, rs => $pkg, r => "$self->{schema}::Result::$table", table => $pkg->table };
    return bless $self->{resultset}, "$self->{schema}::ResultSet::$table";
}

1;
