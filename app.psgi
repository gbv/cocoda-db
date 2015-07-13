use lib 'local/lib/perl5';
use lib 'lib';

use Dancer;
use Plack::Builder;
use Cocoda::API;

builder {
    enable 'ConditionalGET';
    enable 'ETag';
    enable 'JSONP';
    enable 'CrossOrigin', origins => '*';
    dance;
};
