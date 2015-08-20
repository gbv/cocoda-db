use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;
use JSON;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

my $res = $app->request(GET "/");
is $res->code, 200, '/OK';
my $base = decode_json($res->content);
ok $base->{version}, 'has version';

foreach my $method (qw(mappings)) {
    my $path = $base->{$method};
    ok $path, "has $method";
    $res = $app->request(GET $path);
    is $res->code, 200, "$path OK";
}

#note explain $res->as_string;

done_testing;
