use v5.14.1;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use HTTP::Request::Common;
use Catmandu qw(store importer);
use Clone qw(clone);
use JSON;

plan skip_all => 'only local test' if $ENV{TEST_URL};

BEGIN { $ENV{COCODA_DB_CONF}='t/config/test.yml' }
my $app = Plack::Test->create(load_app('app.psgi'));


my @endpoints = qw(concepts schemes types mappings);

# import stuff for testing
{
    my $in = importer('JSKOS', file => 'examples/jskos-schemes.json')->to_array;
    my $expect = clone($in);

    store('schemes')->delete_all;
    store('schemes')->add_many($in);

    $_->{'@context'} = 'http://gbv.github.io/jskos/context.json' for @$expect;

    my $res = $app->request(GET "/s");
    is_deeply decode_json($res->content), $expect, 'got back schemes';
}


my $in = importer('JSKOS', file => 'examples/jskos-concepts.json')->to_array;
store('concepts')->add_many($in);

{
    my $res = $app->request(GET "/c");

    ok my $jskos = decode_json($res->content), 'got back concepts';
    is @$jskos, 2, 'got back 2 concepts';
     
    is $res->header('X-Total-Count'), 3, 'X-Total-Count header';

    if(0) {    # FIXME
    is $res->header('Link'), 
        '<http://localhost/?page=2>; rel="next", <http://localhost/?page=2>; rel="last"',
        'Link header';

    $res = $app->request(GET "/c?page=2");

    is $res->header('Link'), 
        '<http://localhost/?page=1>; rel="first", <http://localhost/?page=1>; rel="prev", <http://localhost/?page=2>; rel="last"',
        'Link header (page=2)';
    }
}

{
    my $res = $app->request(GET "/c?uri=http://example.org/concept/2&unique=1");
    my $jskos = decode_json($res->content);
    is_deeply $jskos->{narrower}, [{
         notation => [ 'C' ],
         uri => 'http://example.org/concept/3'
       }], 'got expanded by uri with unique';
}

{
    my $res = $app->request(GET "/c?notation=A");
    is $res->header('X-Total-Count'), 1, 'got by notation';

#    $res = $app->request(GET "/c?broader=http://example.org/concept/2");
#    is $res->header('X-Total-Count'), 1, 'got by broader';
#    note $res->content;
}

# clean up
Catmandu->store($_)->delete_all for @endpoints;

done_testing;
