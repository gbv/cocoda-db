use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;

$ENV{PLACK_ENV} = 'tests';
my $app = Plack::Test->create( load_app('app.psgi') );

my $res = $app->request(GET "/mappings");
is $res->code, 200, '/mappings OK';

#note explain $res->as_string;

done_testing;
