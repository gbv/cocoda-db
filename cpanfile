requires 'Catmandu', '0.95';             # libcatmandu-perl
requires 'Dancer', '1.3114';             # libdancer-perl
 requires 'JSON', '2.90'; # https://rt.cpan.org/Public/Bug/Display.html?id=90589
requires 'Starman', '0.4008';            # libstarman-perl

requires 'Catmandu::Store::MongoDB';
requires 'Catmandu::Validator::JSONSchema', '0.11';

requires 'Plack::Middleware::ETag'; 
requires 'Plack::Middleware::CrossOrigin'; 
requires 'Plack::Middleware::XForwardedFor'; 

# requires 'Catmandu::Validator::JSONSchema';

test_requires 'Plack::Util::Load';
