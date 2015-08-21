use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

# GET
my $res = $app->request(GET '/');
is $res->code, 200, "200 Ok";
is $res->header('Content-Type'), 'application/json', 'Content-Type';
ok $res->header('ETag'), 'ETag';

done_testing;
