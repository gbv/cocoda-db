use v5.14;
use Test::More;
use Plack::Test;
use Plack::Util::Load;
use Catmandu;

plan skip_all => 'only local test' if $ENV{TEST_URL};

BEGIN { 
    unless ($ENV{TEST_URL}) {
        $ENV{COCODA_DB_CONF}='t/config/test.yml';
        require Cocoda::DB::Config;
        Cocoda::DB::Config->import;
    }
}

is CONFIG('limit.default'), 2, 'local config';
isa_ok( Catmandu->store('foo'), 'Catmandu::Store::MongoDB' );

done_testing;
