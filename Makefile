.PHONY: test

versionfile = VERSION

test:
	bats test

release-bug:
	awk -F'.' '{ print $$1 "." $$2 "." ($$3+1)}' $(versionfile) > $(versionfile).new
	mv $(versionfile).new $(versionfile)
	bin/release

release-improvement:
	awk -F'.' '{ print $$1 "." ($$2+1) ".0"}' $(versionfile) > $(versionfile).new
	mv $(versionfile).new $(versionfile)
	bin/release

release-breakingchange:
	awk -F'.' '{ print ($$1+1) ".0.0"}' $(versionfile) > $(versionfile).new
	mv $(versionfile).new $(versionfile)
	bin/release

clean:
	git checkout $(versionfile)
	rm -rf releases
