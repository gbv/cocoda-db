package Cocoda::API;
use 5.14.1;
use Dancer ':syntax';
use Catmandu ':load';

our $VERSION = '0.0.1';

set serializer => 'JSON';

sub map_properties {
    my ($iter, $default) = @_;

    my %properties = map { ($_ => 1) }
                     split /\s*,\s*/,
                     (param('properties') // $default // '');

    return $iter if !%properties or $properties{'*'};

    $properties{uri} = 1;
    if ($properties{label}) {
        $properties{$_} = 1 for qw(prefLabel altLabel hiddenLabel);
    }

    $iter->map(sub {
        my $item = shift;
        return {
            map { $_ => $item->{$_} }
            grep { defined $item->{$_} } 
            keys %properties 
        }
    });
}

get '/mappings' => sub {
    state $bag = Catmandu->store('mappings')->bag;

    # query fields
    my %fields = (
        fromScheme   => 'from.inScheme',   # .uri ??
        toScheme     => 'to.inScheme',     # .uri ??
        fromNotation => 'from.conceptSet.notation',
        toNotation   => 'to.conceptSet.notation',
        fromConcept  => 'from.conceptSet.uri',
        toConcept    => 'to.conceptSet.uri',
    );
    my $query = {};
    foreach (keys %fields) {
        next unless defined param $_;
        $query->{ $fields{$_} } = param $_;
    }

    # pagination
    no warnings 'numeric', 'uninitialized';
    my $limit  = int(param 'limit') || 20; # TODO: maximum?
    my $page   = int(param 'page') || 1;
    my $unique = !! param 'unique';

    # search
    my $hits = $bag->search( 
        query => $query,
        start => ($page-1)*$limit,
        limit => $limit,
    );

    # TODO: build HTTP header links with total, start, limit, more
 
    # TODO: use MongoDB projection instead (?)
    $hits = map_properties($hits);

    # TODO: support param 'unique'

    $hits->to_array;    
};

true;
