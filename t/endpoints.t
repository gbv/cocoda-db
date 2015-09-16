use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;
use Catmandu;
use JSON;

plan skip_all => 'only local test' if $ENV{TEST_URL};

BEGIN { $ENV{COCODA_DB_CONF}='t/config/test.yml' }
my $app = Plack::Test->create(load_app('app.psgi'));

foreach (qw(concepts schemes types mappings)) {
    Catmandu->store($_)->delete_all;
    
    my $path = substr $_, 0, 1;
    my $res  = $app->request(GET "/$path");
    is $res->code, 200, "GET /$path";
    like $res->header('Content-Type'), 
        qr{^application/json(; charset=utf-8)?$}, 'JSON';
    is_deeply( decode_json($res->content), [], 'empty' );

    # TODO: import stuff for testing
    #  Catmandu->store($_)->delete_all;
}

done_testing;
