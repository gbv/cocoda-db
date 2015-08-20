use v5.14.1;
use lib 'local/lib/perl5';
use lib 'lib';

use Dancer;
use Plack::Builder;
use Cocoda::API;

builder {
    enable 'ConditionalGET';
    enable 'ETag';
    enable 'JSONP';
    enable 'CrossOrigin',
        origins => '*',
        expose_headers => [qw(Link X-Total-Count)];
    dance;
};
