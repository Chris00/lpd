#	$Id: Makefile,v 1.7 2007/02/15 23:38:51 chris_77 Exp $	

PKGNAME	   = $(shell grep "name" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")
PKGVERSION = $(shell grep "version" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")

OCAMLCFLAGS	= -dtypes
OCAMLOPTFLAGS	= -dtypes -inline 3
OCAMLDOCFLAGS	= -html -stars -colorize-code #-css-style $(OCAMLDOCCSS)

DISTFILES	= INSTALL LICENSE META Make.bat Makefile hosts.lpd \
		  $(wildcard *.ml) $(wildcard *.mli)

MLI_FILES	= $(wildcard *.mli)
DOCFILES	= lpd.mli socket.mli

TARBALL 	= $(PKGNAME)-$(PKGVERSION).tar.gz
ARCHIVE 	= $(shell grep "archive(byte)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")
XARCHIVE 	= $(shell grep "archive(native)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")

default: all

OCAMLPACKS = $(shell grep "requires" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")

.PHONY: all byte opt install install-byte install-opt doc dist
all: byte opt
byte: socket.cma lpd.cma
opt: socket.cmxa lpd.cmxa

# Make the examples
.PHONY: ex examples
ex: lpd_to_win.exe page_counter.exe

lpd_to_win.%: OCAMLC_FLAGS += -thread
lpd_to_win.%: OCAMLPACKS := $(OCAMLPACKS),threads


# (Un)installation
.PHONY: install uninstall
install: all
	ocamlfind remove $(PKGNAME); \
	[ -f "$(XARCHIVE)" ] && \
	extra="$(XARCHIVE) $(addsuffix .a,$(basename $(XARCHIVE)))"; \
	ocamlfind install $(if $(DESTDIR),-destdir $(DESTDIR)) $(PKGNAME) \
	  $(MLI_FILES) $(CMI_FILES) $(ARCHIVE) META $$extra

installbyte:
	ocamlfind remove $(PKGNAME); \
	ocamlfind install $(if $(DESTDIR),-destdir $(DESTDIR)) $(PKGNAME) \
	$(MLI_FILES) $(CMI_FILES) $(ARCHIVE) META

uninstall:
	ocamlfind remove $(PKGNAME)

# Compile HTML documentation
DOC_DIR=doc
doc: $(DOCFILES) $(CMI_FILES)
	@if [ -n "$(DOCFILES)" ] ; then \
	    if [ ! -x $(DOC_DIR) ] ; then mkdir $(DOC_DIR) ; fi ; \
	    $(OCAMLDOC) -v -d $(DOC_DIR) $(OCAMLDOCFLAGS) $(DOCFILES) ; \
	fi

# Make a tarball
.PHONY: tar
tar: $(TARBALL)
$(TARBALL):
	bzr export $(TARBALL) -r "tag:$(VERSION)"
	@echo "Created tarball '$(TARBALL)'."

######################################################################

OCAMLFIND	= ocamlfind
OCAMLC		= $(OCAMLFIND) ocamlc
OCAMLP4		= $(OCAMLFIND) camlp4o
OCAMLOPT	= $(OCAMLFIND) ocamlopt
OCAMLDEP	= $(OCAMLFIND) ocamldep
OCAMLDOC	= $(OCAMLFIND) ocamldoc

# Generic compilation instructions.

OCAML_PACKAGES=$(if $(OCAMLPACKS), -package $(OCAMLPACKS))

%.cmi: %.mli
	$(OCAMLC) $(PP_FLAGS) $(OCAMLC_FLAGS) $(OCAML_PACKAGES) -c $<

%.cmo: %.ml
	$(OCAMLC) $(PP_FLAGS) $(OCAMLC_FLAGS) $(OCAML_PACKAGES) -c $<

%.cma: %.cmo
	$(OCAMLC) $(PP_FLAGS) -a -o $@ $(OCAMLC_FLAGS) $^

%.cmx: %.ml
	$(OCAMLOPT) $(PP_FLAGS) $(OCAMLOPT_FLAGS) $(OCAML_PACKAGES) -c $<

%.cmxa: %.cmx
	$(OCAMLOPT) $(PP_FLAGS) -a -o $@ $(OCAMLOPT_FLAGS) $^

%.exe: %.cmo socket.cma lpd.cma
	$(OCAMLC) -o $@ $(PP_FLAGS) $(OCAMLC_FLAGS) $(OCAML_PACKAGES) \
	  $(LIBS_CMA) $(filter %.cmo %.cma,$(filter-out $<,$+)) \
	  -linkpkg $<

%.com: %.cmx socket.cmxa lpd.cmxa
	$(OCAMLOPT) -o $@ $(PP_FLAGS) $(OCAMLOPT_FLAGS) $(OCAML_PACKAGES) \
	  $(LIBS_CMXA) $(filter %.cmx %.cmxa,$(filter-out $<,$+)) \
	  -linkpkg $<


.depend.ocaml: $(wildcard *.ml) $(wildcard *.mli)
	@echo "Building $@ ... "
	-@test -z "$^" || $(OCAMLDEP) $(PP_FLAGS) $(SYNTAX_OPTS) $^ > $@
# If we do not force inclusion (e.g. with "-" prefix), then it is not
# recreated and taken into account properly.
include .depend.ocaml


.PHONY:clean
clean:
	rm -f *~ .*~ *.{o,a} *.cm[aiox] *.cmxa *.annot
	rm -rf $(DOC_DIR) $(TARBALL)
	find . -type f -name "*.exe" -perm -u=x -exec rm -f {} \;

.SUFFIXES: .ml .mli .cmi .cmo