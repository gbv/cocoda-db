use v5.14.1;
use Test::More;
use Dancer::Test;

use_ok 'Cocoda::API';

foreach my $method (qw(HEAD GET OPTIONS)) {
    foreach my $route ('', qw(schemes concepts mappings types)) {
        route_exists [$method => "/$route"], "$method /$route";
    }
}

done_testing;
