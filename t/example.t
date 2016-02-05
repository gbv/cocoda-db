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

{
    my $in = importer('JSKOS', file => 'examples/jskos-concepts.json')->to_array;
    store('concepts')->add_many($in);
    my $res = $app->request(GET "/c");

    ok decode_json($res->content);

    # TODO: Test expansion etc.
    # TODO: Test pagination and link header
}

# clean up
Catmandu->store($_)->delete_all for @endpoints;

done_testing;
