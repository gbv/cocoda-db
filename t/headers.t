use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;
use JSON;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

my $res = $app->request(GET "/");
is $res->header('Content-Type'), 'application/json', 'Content-Type';
ok $res->header('ETag'), 'ETag';

my $res = $app->request(
    HTTP::Request->new( OPTIONS => "/", [ Origin => '/' ])
);
is $res->code, 200, 'OPTIONS / Ok';
is $res->header('Access-Control-Allow-Origin'), '*';
is $res->header('Access-Control-Expose-Headers'), 'Link, X-Total-Count';

done_testing;
