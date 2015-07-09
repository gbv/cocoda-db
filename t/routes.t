use v5.14.1;
use Test::More;
use Cocoda::API;
use Dancer::Test;

route_exists [GET => '/mappings'], 
    'a route handler is defined for /mappings';

# FIXME
#response_status_is ['GET' => '/mappings'], 200, 
#    'response status is 200 for /mappings';

done_testing;
