requires 'Catmandu', '0.94';            # libcatmandu-perl
requires 'Dancer', '1.3114';            # libdancer-perl
requires 'Plack', '1.0029';
requires 'Catmandu::Store::MongoDB';
requires 'Plack::Middleware::ETag'; 
requires 'Plack::Middleware::CrossOrigin'; 

# requires 'Catmandu::Validator::JSONSchema';

test_requires 'Plack::Util::Load';

requires 'Starman'; # libstarman-perl
