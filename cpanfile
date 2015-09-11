requires 'Catmandu', '0.94';            # libcatmandu-perl
requires 'Dancer', '1.3114';            # libdancer-perl
requires 'Starman', '0.4008';           # libstarman-perl

requires 'Catmandu::Store::MongoDB';
requires 'Catmandu::Validator::JSONSchema';

requires 'Plack::Middleware::ETag'; 
requires 'Plack::Middleware::CrossOrigin'; 
requires 'Plack::Middleware::XForwardedFor'; 

# requires 'Catmandu::Validator::JSONSchema';

test_requires 'Plack::Util::Load';
