package Cocoda::API;
use 5.14.1;
use Dancer ':syntax';
use Catmandu ':load';

use Cocoda::API::Modifiers;

our $VERSION="0.0.2";
our $JSKOSAPI="0.1.0";

our $CONFIG = {
    pagination => {
        default => 20,
        max     => 1000,
    },
};

set behind_proxy => 1; # TODO: config

our $ENDPOINTS = {
    schemes => {
        href => 'schemes',
    },
    concepts => {
        href => 'concepts',
    },
    mappings => {
        href => 'mappings',
    },
    types => {
        href => 'types',
    }
};

our $DESCRIPTION = {
    version  => $VERSION,
    jskosapi => $JSKOSAPI,
};

our $CONCEPT_SEARCH_FIELDS = {
    map { $_ => $_ } qw(
        uri type prefLabel altLabel hiddenLabel notation broader narrower related
    ),
    # TODO: label (any of prefLabel, altLabel, hiddenLabel)
    # TODO: note (any kind of note)
    scheme         => 'inScheme.uri',
    schemeNotation => 'inScheme.notation',
};

# base URL
get '/' => sub {
    return { %$DESCRIPTION, %$ENDPOINTS }
};

options '/' => sub {
    header('Allow', 'GET, HEAD, OPTIONS');
    return { %$DESCRIPTION, %$ENDPOINTS }
};    

# endpoints
get '/schemes' => sub {
    state $bag = Catmandu->store('schemes')->bag;
    my $fields = {
        map { $_ => $_ } qw(uri type prefLabel altLabel hiddenLabel notation),
        # TODO: label (any of prefLabel, altLabel, hiddenLabel)
    };
    answer_query( $fields, $bag );
};

get '/concepts' => sub {
    state $bag = Catmandu->store('concepts')->bag;
    answer_query( $CONCEPT_SEARCH_FIELDS, $bag );
};

get '/types' => sub {
    state $bag = Catmandu->store('types')->bag;
    answer_query( $CONCEPT_SEARCH_FIELDS, $bag );
};


get '/mappings' => sub {
    state $bag = Catmandu->store('mappings')->bag;

    # query fields
    my $fields = {
        fromScheme         => 'from.inScheme.uri',
        toScheme           => 'to.inScheme.uri',
        fromSchemeNotation => 'from.inScheme.notation',
        toSchemeNotation   => 'to.inScheme.notation',
        fromNotation       => 'from.conceptSet.notation',
        toNotation         => 'to.conceptSet.notation',
        from               => 'from.conceptSet.uri',
        to                 => 'to.conceptSet.uri',
        map { $_ => $_ } qw(
            creator 
            publisher
            contributor
            source
            provenance
            dateAccepted
            dateModified
        ),
    };
    answer_query( $fields, $bag );
};


sub answer_query { # TODO: move to another module
    my ($fields, $bag) = @_;

    # TODO: language tags

    # collect query fields
    my $query = {};
    foreach (keys %$fields) {
        next unless defined param $_;
        $query->{ $fields->{$_} } = param $_;
    }

    # search given bag with pagination
    my $hits = do {
        no warnings 'numeric', 'uninitialized';
        my $page   = int(param 'page') || 1;
        $page = 1 if $page < 1;

        my $limit  = int(param 'limit') || $CONFIG->{pagination}->{default};
        $limit = 1 if $limit < 1;

        if (param 'unique') {
            $limit = 2;
        } else {
            my $max = $CONFIG->{pagination}->{max};
            $limit = $max if $max and $limit > $max;
        }

        # search
        $bag->search( 
            query => $query,
            start => ($page-1)*$limit,
            limit => $limit,
        );
    };

    # filter to requested object properties    
    # TODO: use MongoDB projection instead (?)
    $hits = filter_properties($hits);

    # TODO: implement 'list' modifier
    # TODO: JSKOS expansion and normalization

    return_paginated($query, $hits);
}


### CORS and OPTIONS

options qr{^/(mappings|schemes|concepts|types)} => sub {
    header('Allow', 'GET, HEAD, OPTIONS');
    my ($endpoint) = splat;
    return {
        %$DESCRIPTION,
        $endpoint => $ENDPOINTS->{$endpoint},
    }
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
