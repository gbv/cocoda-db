package Cocoda::API;
use 5.14.1;
use Dancer ':syntax';
use Catmandu ':load';

our $VERSION="0.0.1";

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

get '/' => sub {
    {
        version => $VERSION,
        schemes => '/schemes',
        concepts => '/concepts',
        mappings => '/mappings',
    }
};

get '/schemes' => sub {
    state $bag = Catmandu->store('schemes')->bag;
    []
};

get '/concepts' => sub {
    state $bag = Catmandu->store('concepts')->bag;
    []
};

sub search_with_pagination {
    my ($bag, $query) = @_;
    
    # pagination
    no warnings 'numeric', 'uninitialized';
    my $page   = int(param 'page') || 1;
    my $limit  = int(param 'limit') || 20; # TODO: configure value
    if (param 'unique') {
        $limit = 2;
    } elsif ($limit > 1000) { # TODO: configure value
        $limit = 1000;
    }

    # search
    my $hits = $bag->search( 
        query => $query,
        start => ($page-1)*$limit,
        limit => $limit,
    );
}

sub return_hits {
    my ($hits) = @_;
    
    if (param 'unique') {
        if ($hits->total == 1) {
            $hits->first;
        } elsif ($hits->total == 0) {
            status(404);
            { "error" => "not found" };
        } else {
            status(303);
            { "error" => "multiple choices (parameter unique)" };
        }
    } else {
        header('X-Total-Count' => $hits->total);
        my $limit = $hits->limit; 
        my ($next, $last) = ($hits->next_page, $hits->last_page);
        my @links = (
            "limit=$limit>; rel=\"first\"",
            "page=$last&limit=$limit>; rel=\"last\"",
        );
        if ($next) {
            push @links, "page=$next&limit=$limit>; rel=\"next\""
        }
        # TODO: use configured base URL and add additional query parameters
        my $base = request->base."?";
        header('Link' => join ', ', map { "<$base$_" } @links);
        $hits->to_array;
    }
}

get '/mappings' => sub {
    state $bag = Catmandu->store('mappings')->bag;

    # TODO: author
    
    # query fields
    my %fields = (
        fromScheme         => 'from.inScheme.uri',
        toScheme           => 'to.inScheme.uri',
        fromSchemeNotation => 'from.inScheme.notation',
        toSchemeNotation   => 'to.inScheme.notation',
        fromNotation       => 'from.conceptSet.notation',
        toNotation         => 'to.conceptSet.notation',
        from               => 'from.conceptSet.uri',
        to                 => 'to.conceptSet.uri',
        map { $_ => $_ } qw(creator publisher contributor source provenance dateAccepted dateModified),
    );
    my $query = {};
    foreach (keys %fields) {
        next unless defined param $_;
        $query->{ $fields{$_} } = param $_;
    }

    my $hits = search_with_pagination($bag, $query);
    # TODO: build HTTP header links with total, start, limit, more
 
    # TODO: props of from and to instead
    # TODO: use MongoDB projection instead (?)
    $hits = map_properties($hits);

    return_hits($hits);
};

### CORS

options qr{^/(mappings|schemes|concepts)?} => sub {
    # TODO: remove content afterwards?
    return { }
};

# TODO: other pathes as well

### Logging and error handling

# custom 404
any qr{.*} => sub {
    status 404;
    halt {
        code => 404,
        error => 'not found',
        description => 'no content found at this URL',
    };
};

# catch internal exception and return an error message
hook on_route_exception => sub {
    my $exception = shift;

    # add some details on error level
    my $msg = $exception->message;
    if ($exception->can('previous_exception')) {
        $msg .= "\n".$exception->previous_exception;
    }
    error $msg;

    # include stack trace on debug level
    if (ref $exception->{stack_trace}) {
        debug $msg.$exception->{stack_trace}->as_string;
    }

    # return without details
    status 500;
    halt { 
        code => 500, 
        description => 'an internal error occurred', 
        error => $exception->message,
    };
};

# log after each response on debug level to evaluate requests
hook 'after' => sub {
    debug 'HTTP '.shift->status;
};

true;
