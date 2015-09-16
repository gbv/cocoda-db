use v5.14;
use Test::More;
use Plack::Test;
use Plack::Util::Load;

plan skip_all => 'only local test' if $ENV{TEST_URL};

BEGIN { $ENV{COCODA_DB_CONF}='t/config/test.yml' }
use Cocoda::DB::Config;
use Catmandu;

is CONFIG('limit.default'), 2, 'local config';
isa_ok( Catmandu->store('foo'), 'Catmandu::Store::MongoDB' );

done_testing;
