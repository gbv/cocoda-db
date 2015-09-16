use v5.14.1;
use lib 'local/lib/perl5';
use lib 'lib';

use Dancer qw(set dance);
use Plack::Builder;
use Cocoda::DB::Config;
use Cocoda::API;

builder {
    enable_if { CONFIG('proxy') } 'XForwardedFor', 
        trust => CONFIG('proxy') // [];
    enable 'ConditionalGET';
    enable 'Head';
    enable 'ETag';
    enable 'JSONP';
    enable 'CrossOrigin',
        origins => '*',
        headers => ['Authorization'],
        methods => [qw{GET HEAD OPTIONS}],
        expose_headers => [qw(Link Server X-Total-Count)];
    dance;
};
