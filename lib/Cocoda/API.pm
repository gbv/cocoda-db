package Cocoda::API;
use 5.14.1;
use Dancer ':syntax';

use Cocoda::DB::Config;
use Catmandu '-load';

use Cocoda::API::Query;

our $VERSION="0.0.6";
our $JSKOS_API_VERSION="0.0.0";

our $CONCEPT_SEARCH_FIELDS = {
    (map { $_ => $_ } qw(
        uri type prefLabel altLabel hiddenLabel notation broader narrower related
    )),
    # TODO: label (any of prefLabel, altLabel, hiddenLabel)
    # TODO: note (any kind of note)
    scheme         => 'inScheme.uri',
    topConceptOf   => 'topConceptOf.uri',
    schemeNotation => 'inScheme.notation',
    broader        => 'broader.uri',
    narrower       => 'narrower.uri',
};

sub service_description {
    my (@endpoints) = @_ ? @_ : qw(concepts schemes mappings types);

    return {
        version  => $VERSION,
        jskosapi => $JSKOS_API_VERSION,
        CONFIG(title => 'title'),
        map {
            $_ => {
                CONFIG(href => "endpoints.$_.href"),
                CONFIG(title => "endpoints.$_.title"),
            }
        } 
        grep { CONFIG("endpoints.$_") }
        @endpoints
    }
}

# base URL
get '/' => sub {
    return service_description;
};

options '/' => sub {
    header('Allow', 'GET, HEAD, OPTIONS');
    return service_description;
};    


my %endpoints = (
    concepts => sub {
        state $bag = Catmandu->store('concepts')->bag;
        state $builder = query_builder($CONCEPT_SEARCH_FIELDS);
        answer_query( $builder->(), $bag );
    },
    schemes => sub {
        state $bag = Catmandu->store('schemes')->bag;
        state $builder = query_builder( {
            map { $_ => $_ }
            qw(uri type prefLabel altLabel hiddenLabel notation),
            # TODO: label (any of prefLabel, altLabel, hiddenLabel)
        } );
        answer_query( $builder->(), $bag );
    },
    types => sub {
        state $bag = Catmandu->store('types')->bag;
        state $builder = query_builder($CONCEPT_SEARCH_FIELDS);
        answer_query( $builder->(), $bag );
    },
    mappings => sub {
        state $bag = Catmandu->store('mappings')->bag;
        state $builder = query_builder( { 
            fromScheme         => 'from.inScheme.uri',
            toScheme           => 'to.inScheme.uri',
            fromSchemeNotation => 'from.inScheme.notation',
            toSchemeNotation   => 'to.inScheme.notation',
            fromNotation       => 'from.members.notation',
            toNotation         => 'to.members.notation',
            from               => 'from.members.uri',
            to                 => 'to.members.uri',
            map { $_ => $_ } qw(
                creator 
                publisher
                contributor
                source
                provenance
                dateAccepted
                dateModified
            ),
        } );
        answer_query( $builder->(), $bag );
    }
);

while (my ($name, $sub) = each %endpoints) {
    my $href = CONFIG("endpoints.$name.href");
    next if $href and $href =~ qr{^(https?:)?//};
    
    get "/$href" => $sub;

    options "/$href" => sub {
        header('Allow', 'GET, HEAD, OPTIONS');
        return service_description($name);
    };
}

### Common headers

hook before_serializer => sub {
    header 'X-JSKOS-API-Version' => $JSKOS_API_VERSION;
    my $link = request->base; # TODO: URI template
    header('Link-Template', "<$link>; rel=\"search\"" );
};

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
    if (ref $exception and $exception->{stack_trace}) {
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
