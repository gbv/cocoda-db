package Cocoda::DB::Config;
use v5.14.1;

use Dancer qw(set config);
use YAML ();

use parent 'Exporter';
our @EXPORT = qw(CONFIG);

# load instance config before compilation of Cocoda::API
BEGIN {
    my ($file) = grep { -f $_ } qw(etc/config.yml /etc/cocoda-db/config.yml);
    my $etc = eval { YAML::LoadFile($file) }
           or die "Unable to parse the configuration file: $file: $@";

    # set possibly missing default values
    my $endpoints = $etc->{endpoints};
    foreach (qw(concepts schemes types mappings)) {
        if ($endpoints->{$_} and !defined $endpoints->{$_}->{href}) {
            $endpoints->{$_}->{href} = $_;
        }
    }

    set etc => $etc;
    set behind_proxy => 1 if $etc->{proxy};
}

# local instance configuration
# Call as CONFIG(path) or CONFIG(key => path).
sub CONFIG {
    my $v = config->{etc};
    $v = $v->{$_} // return () for split '\.', pop;
    return (@_ ? ($_[0] => $v) : $v);
}

1;
