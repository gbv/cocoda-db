# extract build information from control file and changelog
POPEN  :=(
PCLOSE :=)
PACKAGE:=$(shell perl -ne 'print $$1 if /^Package:\s+(.+)/;' < debian/control)
VERSION:=$(shell perl -ne '/^.+\s+[$(POPEN)](.+)[$(PCLOSE)]/ and print $$1 and exit' < debian/changelog)
ARCH   :=$(shell perl -ne 'print $$1 if /^Architecture:\s+(.+)/;' < debian/control)
RELEASE:=${PACKAGE}_${VERSION}_${ARCH}.deb
MAINSRC:=lib/Cocoda/API.pm

info:
	@echo "Release: $(RELEASE)"

version:
	@perl -p -i -e 's/^our\s+\$$VERSION\s*=.*/our \$$VERSION="$(VERSION)";/' $(MAINSRC)
	@perl -p -i -e 's/^our\s+\$$NAME\s*=.*/our \$$NAME="$(PACKAGE)";/' $(MAINSRC)

# build documentation (TODO: also build PDF and HTML)
PANDOC = $(shell which pandoc)
ifeq ($(PANDOC),)
  PANDOC = $(error pandoc is required but not installed)
endif

docs: debian/$(PACKAGE).1
debian/$(PACKAGE).1: README.md debian/control
	@grep -v '^\[!' $< | $(PANDOC) -s -t man -o $@ \
		-M title="$(shell echo $(PACKAGE) | tr a-z A-Z)(1) Manual" -o $@

# build Debian package
deb: docs version
	prove -l -Ilocal/lib/perl5
	dpkg-buildpackage -b -us -uc -rfakeroot
	mv ../$(PACKAGE)_$(VERSION)_*.deb .

# install required toolchain and Debian packages
dependencies:
	apt-get install fakeroot dpkg-dev
	apt-get install pandoc libghc-citeproc-hs-data 
	apt-get install `perl -ne 'next if /^#/; $$p=(s/^(Depends:\s*)/ / or (/^ / and $$p)); s/,|\n|\([^)]+\)//mg; print if $$p' < debian/control`

local: cpanfile
	cpanm -l local --skip-satisfied --no-man-pages --notest --installdeps .

dance:
	plackup -Ilib -r app.psgi

tests:
	prove -Ilocal/lib/perl5 -l -v
