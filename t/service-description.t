use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request;
use JSON;

my $env = $ENV{TEST_URL} || 'app.psgi';
my $app = Plack::Test->create( load_app($env) );

# service description at base URL
my $res = $app->request(HTTP::Request->new(GET => '/'));
is $res->code, 200, 'GET / OK';
is $res->header('Content-Type'), 'application/json', 'JSON';

my $service = decode_json($res->content);
like $service->{'jskosapi'}, qr{^\d+\.\d+\.\d+$}, 'jskosapi';

# service description at endpoints
foreach (qw(concepts schemes mappings types)) {
    my $path = $service->{$_}->{href};
    ok $path, $path;
    
    my $res  = $app->request(HTTP::Request->new(OPTIONS => $path));
    is $res->code, 200, "OPTIONS";
    is $res->header('Content-Type'), 'application/json', 'JSON';
    is $res->header('Allow'), 'GET, HEAD, OPTIONS', 'Allow'; 

    my $s = decode_json($res->content);
    like $s->{'jskosapi'}, qr{^\d+\.\d+\.\d+$}, 'jskosapi';

    is_deeply $s->{$_}, $service->{$_}, "$_ service description";
}

done_testing;
