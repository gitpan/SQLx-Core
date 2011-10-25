package SQLx::Core;

use 5.010;
use DBI;

use base qw/
    SQLx::Core::Schema
    SQLx::Core::ResultSet
    SQLx::Core::Result
/;

$SQLx::Core::VERSION = '0.05';

=head1 NAME

SQLx::Core - Object Oriented SQL Queries in Perl.

=head1 DESCRIPTION

Access the DBI module in a friendly, and OO fashion. Create sub-routines for your results 
and manipulate them in any way possible by Perl.
As of 0.02 you can now chain custom methods together for more powerful search results.

=head1 SYNOPSIS

    # MySchema.pm
    package MySchema;
    use base 'SQLx::Core';
    
    use MySchema::ResultSet::MyTable;
    use MySchema::Result::MyTable;

    1;

    # MySchema/ResultSet/MyTable.pm
    package MySchema::ResultSet::MyTable;

    use base 'SQLx::Core';

    sub table { 'my_real_table_name'; } # Important!

    sub rows { return shift->count; }
    
    1;

    # MySchema/Result/MyTable.pm
    package MySchema::Result::MyTable;
    
    use base 'SQLx::Core';
    
    # create a simple accessor
    sub name {
        my $self = shift;
        return $self->{name};
    }

    sub id { return shift->{id}; }

    1;

    # test.pl
    use MySchema;

    my $schema = MySchema->connect(
        dbi => 'SQLite:test.db',
    );

    my $rs = $schema->resultset('MyTable');
    my $rset = $rs->search([], { status => 'active' });
    
    # "rows" is the resultset method we created
    print "Rows: " . $rset->rows . "\n";
    while(my $row = $rset->next) {
        print $row->id;
    }

    my $rset2 = $rs->find([], { id => 4 });
    print $rset2->name . "\n";

    # slurp all results into a resultset
    my $all = $rs->all;

    # get the first and last results.. plus we want the name using our result method
    my $last_name = $rs->all->last->name;
    my $first_name = $rs->all->first->name;

    # update rows
    my $s = $rs->search([], { status => 'disabled' });
    $s->update({status => 'active'});

=cut

=head2 connect

Creates the Schema instance using the hash specified. Currently only dbi is mandatory, 
which tells DBI which engine to use (SQLite, Pg, etc).
If you're using SQLite there is no need to set user or pass.

    my $dbh = SQLx::Core->connect(
        dbi => 'SQLite:/var/db/test.db',
    );

    my $dbh = SQLx::Core->connect(
        dbi  => 'Pg:host=myhost;dbname=dbname',
        user => 'username',
        pass => 'password',
    );

=cut

sub connect {
    my ($class, %args) = @_;

    my $dbh = DBI->connect(
        'dbi:' . $args{dbi},
        $args{user}||undef,
        $args{pass}||undef,
        { PrintError => 0 }
    ) or do {
        warn 'Could not connect to database: ' . $DBI::errstr;
        return 0;
    };

    my $dbhx = { dbh => $dbh, schema => $class };
    bless $dbhx, 'SQLx::Core::Schema';
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

Same license as Perl

=cut

1;
