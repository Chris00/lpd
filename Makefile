PKGVERSION = $(shell git describe --always)

all build byte native:
	jbuilder build @install @examples #--dev
	jbuilder build @runtest --force

install uninstall doc:
	jbuilder $@

lint:
	@opam lint lpd.opam

clean:
	jbuilder clean

.PHONY: all build byte native install uninstall doc lint clean
