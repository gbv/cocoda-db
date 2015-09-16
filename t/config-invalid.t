use v5.14;
use Test::More;
use Plack::Test;
use Plack::Util::Load;

plan skip_all => 'only local test' if $ENV{TEST_URL};

$ENV{COCODA_DB_CONF}='t/config/invalid.yml';
ok !eval { Plack::Test->create(load_app('app.psgi')) };
like $@, qr{Invalid configuration file t/config/invalid.yml};

done_testing;
