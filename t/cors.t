use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

# request with Origin header
sub CORS {
    my ($method, $url) = (shift, shift);
    my $req = HTTP::Request->new($method => $url, [ Origin => $url, @_ ]);
    my $res = $app->request($req);
    is $res->code, 200, "$method $url Ok";
    is $res->header('Access-Control-Allow-Origin'), 
        '*', 
        'Access-Control-Allow-Origin';
    is $res->header('Access-Control-Expose-Headers'), 
        'Link, Server, X-Total-Count', 
        'Access-Control-Expose-Headers';
    $res;
}

# GET
my $res = CORS(GET => '/');

# OPTIONS Preflight request
$res = CORS(OPTIONS => "/", 
    'Access-Control-Request-Method' => 'GET',
    'Access-Control-Request-Headers' => 'Foo', # just allow any request header
);
is $res->content, '', 'no body';
is $res->header('Access-Control-Allow-Methods'), 'GET, HEAD, OPTIONS';
is $res->header('Access-Control-Allow-Headers'), 'Foo';

# OPTIONS
$res = CORS(OPTIONS => "/");
is $res->header('Allow'), 'GET, HEAD, OPTIONS'; 
# note $res->content;

$res = CORS(OPTIONS => "/mappings");
is $res->header('Allow'), 'GET, HEAD, OPTIONS'; 
# note $res->content;

done_testing;
