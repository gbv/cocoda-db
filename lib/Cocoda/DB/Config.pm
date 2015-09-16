package Cocoda::DB::Config;
use v5.14.1;

use Dancer qw(set config debug);
use YAML ();
use JSON::Schema;
use Try::Tiny;
use Catmandu;

use parent 'Exporter';
our @EXPORT = qw(CONFIG);

# load instance config before compilation of Cocoda::API
BEGIN {
    my $file = $ENV{COCODA_DB_CONF} //
        (-f 'etc/config.yml' ? 'etc/config.yml' : '/etc/cocoda-db/config.yml');

    my $etc = try { YAML::LoadFile($file) }
              catch { die "Failed to load configuration file $file: $_\n" };

    # validate config file
    my $schema = YAML::LoadFile("config-schema.yml");
    my $result = JSON::Schema->new($schema)->validate($etc);
    unless ($result) {
        die join "\n", "Invalid configuration file $file", $result->errors, '';
    }

    debug "Using config file $file\n";

    for (grep {defined} $etc->{_catmandu}) {
        debug "Using catmandu config path $_"; 
        Catmandu->default_load_path($_);
    }

    set etc => $etc;
    set behind_proxy => 1 if $etc->{proxy};
}


# local instance configuration
# Call as CONFIG(path) or CONFIG(key => path).
sub CONFIG($;$) {
    my $v = config->{etc} // { };
    my $path = pop;
    $v = $v->{$_} // return () for split '\.', $path;
    return (@_ ? ($_[0] => $v) : $v);
}

1;
