package SQLx::Core::Schema;

our $VERSION = '0.08';

sub resultset {
    my ($self, $table) = @_;

    my $pkg = "$self->{schema}::ResultSet::$table";
    $self->{resultset} = { dbh => $self->{dbh}, rs => $pkg, r => "$self->{schema}::Result::$table", table => $pkg->table };
    return bless $self->{resultset}, "$self->{schema}::ResultSet::$table";
}

sub load_namespaces {
    my $class = shift;
    use Module::Finder;
    my $class_d = $class;
    $class_d =~ s/::/\-/g;
    $class_d = "$class_d/lib/";
    print $class_d . "\n";
    my $mf = Module::Finder->new(
        dirs  => [$class_d],
        paths => {
            $class => '/',
        }
    );
    my @modnames = $mf->modules;
    my $usem = "";
    for(@modnames) {
        $usem .= "use $_;\n";
    }
    eval $usem;
}

1;
