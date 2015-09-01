use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;

my $env = $ENV{TEST_URL} || 'app.psgi';
my $app = Plack::Test->create( load_app($env) );

# GET
my $res = $app->request(GET '/');
is $res->code, 200, "200 Ok";
like $res->header('Content-Type'), 
    qr{^application/json(; charset=utf-8)?$}, 'Content-Type';

ok $res->header('ETag'), 'ETag';

# HEAD
$res = $app->request(HEAD '/');
is $res->code, 200, "200 Ok";
is $res->content, '', 'HEAD request';

done_testing;
