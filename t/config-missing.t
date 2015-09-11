use v5.14;
use Test::More;
use Plack::Util::Load;

plan skip_all => 'only local test' if $ENV{TEST_URL};

$ENV{COCODA_DB_CONF}='t/config/missing.yml';
ok !eval { Plack::Test->create(load_app('app.psgi')) };
like $@, qr{Failed to load configuration file t/config/missing.yml};

done_testing;
