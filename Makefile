PKGVERSION = $(shell git describe --always)

all build byte native:
	jbuilder build @install @examples --dev
	jbuilder build @runtest --force

install uninstall:
	jbuilder $@

doc: all
	sed -e 's/%%VERSION%%/$(PKGVERSION)/' src/lpd.mli \
	  > _build/default/src/lpd.mli
	jbuilder build @doc

lint:
	@opam lint lpd.opam

clean:
	jbuilder clean

.PHONY: all build byte native install uninstall doc lint clean
