local: cpanfile
	cpanm -l local --skip-satisfied --installdeps .

dance:
	plackup -Ilib -r app.psgi

tests:
	prove -Ilocal/lib/perl5 -l -v
