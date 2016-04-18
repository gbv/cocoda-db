package Cocoda::API::Query;
use 5.14.1;

use parent 'Exporter';
our @EXPORT = qw(query_builder answer_query);

use Cocoda::DB::Config;
use Catmandu '-load';
use Cocoda::API::Modifiers;
use Dancer ':syntax';

my $jskos_export_fix = do 'fixes/jskos-export.pl';

# returns a function to build query object from request parameters
sub query_builder {
    my ($fields) = @_;

    my $fix = Catmandu->fixer(
        join "\n",
        map { sprintf "if exists($_) move_field($_,%s) end", $fields->{$_} } 
        grep { $_ ne $fields->{$_} } keys %$fields
    );


    sub {

        # collect all known query parameters
        my $query = {};        
        foreach (keys %$fields) {
            my $value = param($_) // next;
            $query->{$_} = $value;
        }

        # map query parameters
        $fix->fix($query);
    }
}

sub answer_query {
    my ($query, $bag) = @_;

    # TODO: language tags

    debug $query;

    # search given bag with pagination
    my $hits = do {
        no warnings 'numeric', 'uninitialized';
        my $page   = int(param 'page') || 1;
        $page = 1 if $page < 1;

        my $limit  = int(param 'limit') || CONFIG('limit.default');
        $limit = 1 if $limit < 1;

        if (param 'unique') {
            $limit = 2;
        } else {
            my $max = CONFIG('limit.max');
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

    # expand a single object
    if ($query->{uri} and $hits->first) {
        my $item = $hits->first;
        my $uri  = $item->{uri};
        debug "expanding $uri";

        if (!$item->{narrower}) {
            $item->{narrower} = [ ];
            my $narrowerHits = $bag->search(
                query => { 'broader.uri' => $uri },
                limit => 100, # TODO
            );
            $narrowerHits->each(sub {
                my $narrower = shift;
                my $n = { };
                foreach my $field (qw(uri prefLabel notation)) {
                    $n->{$field} = $narrower->{$field} if defined $narrower->{$field};
                }
                push @{$item->{narrower}}, $n;
            });
            # TODO: if more than 100
            # TODO: keep empty array for concepts only
            delete $item->{narrower} unless @{$item->{narrower}};
        }
    }

    # TODO: implement 'list' modifier
    # TODO: JSKOS expansion and normalization

    return_paginated($query, $hits, $jskos_export_fix);
}

1;
