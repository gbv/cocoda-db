package Cocoda::API::Modifiers;
use 5.14.1;

use parent 'Exporter';
our @EXPORT = qw(link_header filter_properties return_paginated);

use URI;
use URI::QueryParam;
use Dancer ':syntax';
use Cocoda::DB::Config;

# Filter response to selected properties only
sub filter_properties {
    my ($hits, $default) = @_;

    my %properties = map { ($_ => 1) }
                     split /\s*,\s*/,
                     (param('properties') // $default // '');

    # no filter (TODO: default properties)
    return $hits if !%properties or $properties{'*'};

    # which properties to return
    $properties{uri} = 1;
    if ($properties{label}) {
        $properties{$_} = 1 for qw(prefLabel altLabel hiddenLabel);
    }

    $hits->map(sub {
        my $item = shift;
        return {
            map { $_ => $item->{$_} }
            grep { defined $item->{$_} } 
            keys %properties 
        }
    });
}

# Build HTTP Response Link header for pagination
sub link_header {
    my ($base, $query, $hits) = @_;

    my $url = URI->new($base);
    $url->query_form(%$query);

    my @links;

    if ($hits->limit != CONFIG('limit.default')) {
        $url->query_param( limit => $hits->limit );
    }

    if ($hits->first_page < $hits->page) {
        $url->query_param( page => $hits->first_page );
        push @links, "<$url>; rel=\"first\"";

        $url->query_param( page => $hits->previous_page );
        push @links, "<$url>; rel=\"prev\"";
    }

    if ($hits->next_page) {
        $url->query_param( page => $hits->next_page );
        push @links, "<$url>; rel=\"next\"";
    }

    if ($hits->last_page) {
        $url->query_param( page => $hits->last_page );
        push @links, "<$url>; rel=\"last\"";
    }

    return (join ', ', @links);
}

# page, limit, unique
sub return_paginated {    
    my ($query, $hits, $map) = @_;

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
        header('Link', link_header( request->base, $query, $hits ));
        $hits = $hits->map($map) if $map;
        $hits->to_array;
    }
}

1;
