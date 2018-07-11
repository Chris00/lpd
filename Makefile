PKGVERSION = $(shell git describe --always)

all build byte native:
	dune build @install @examples
	dune build @runtest --force

install uninstall:
	dune $@

doc: all
	sed -e 's/%%VERSION%%/$(PKGVERSION)/' src/lpd.mli \
	  > _build/default/src/lpd.mli
	dune build @doc

lint:
	@opam lint lpd.opam

clean:
	dune clean

.PHONY: all build byte native install uninstall doc lint clean
