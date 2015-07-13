use v5.14.1;
use Test::More;
use Dancer::Test;

use_ok 'Cocoda::API';

foreach (qw(schemes concepts mappings)) {
    route_exists [GET => "/$_"], "a route handler is defined for /$_";
}

done_testing;
