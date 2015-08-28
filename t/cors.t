use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

# request with Origin header
sub CORS {
    my $url = shift;
    my $req = HTTP::Request->new(OPTIONS => $url, [ Origin => $url, @_ ]);
    my $res = $app->request($req);
    is $res->code, 200, "CORS $url Ok";
    is $res->header('Access-Control-Allow-Origin'), 
        '*', 'Access-Control-Allow-Origin';
    is $res->header('Access-Control-Expose-Headers'), 
        'Link, Server, X-Total-Count', 'Access-Control-Expose-Headers';
    $res;
}

# OPTIONS Preflight request
my $res = CORS('/',
    'Access-Control-Request-Method'  => 'GET',
    'Access-Control-Request-Headers' => 'Authorization',
);
is $res->content, '', 'no body';
is $res->header('Access-Control-Allow-Methods'), 'GET, HEAD, OPTIONS';
is $res->header('Access-Control-Allow-Headers'), 'Authorization';

# Plain OPTIONS without Access-Control- request headers
my $res = CORS('/');
is $res->code, 200, 'Ok';

done_testing;
