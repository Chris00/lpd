#	$Id: Makefile,v 1.7 2007/02/15 23:38:51 chris_77 Exp $	

PKGNAME	   = $(shell grep "name" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")
PKGVERSION = $(shell grep "version" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")

SRC_WEB    = web
SF_WEB     = /home/groups/o/oc/ocaml-lpd/htdocs

CAMLPATH	= 
OCAMLC		= $(CAMLPATH)ocamlc
OCAMLP4		= $(CAMLPATH)camlp4o
OCAMLOPT	= $(CAMLPATH)ocamlopt
OCAMLDEP	= $(CAMLPATH)ocamldep
OCAMLDOC	= $(CAMLPATH)ocamldoc

OCAMLCFLAGS	= -dtypes
OCAMLOPTFLAGS	= -dtypes -inline 3
OCAMLDOCFLAGS	= -html -stars -colorize-code #-css-style $(OCAMLDOCCSS)

DISTFILES	= INSTALL LICENSE META Make.bat Makefile hosts.lpd \
		  $(wildcard *.ml) $(wildcard *.mli)

MLI_FILES	= $(wildcard *.mli)
DOCFILES	= lpd.mli socket.mli

PKG_TARBALL 	= $(PKGNAME)-$(PKGVERSION).tar.gz
ARCHIVE 	= $(shell grep "archive(byte)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")
XARCHIVE 	= $(shell grep "archive(native)" META | \
			sed -e "s/.*\"\([^\"]*\)\".*/\1/")

default: all

######################################################################

PKGS = $(shell grep "requires" META | sed -e "s/.*\"\([^\"]*\)\".*/\1/")
PKGS_CMA 	= $(addsuffix .cma, $(PKGS))
PKGS_CMXA 	= $(addsuffix .cmxa, $(PKGS))

CMI_FILES	= $(MLI_FILES:.mli=.cmi)

.PHONY: all byte opt install install-byte install-opt doc dist
all: byte opt
byte: socket.cma lpd.cma
opt: socket.cmxa lpd.cmxa


# Make the examples
.PHONY: ex examples
ex: lpd_to_win.exe page_counter.exe

%.exe: socket.cma lpd.cma %.ml
	$(OCAMLC) $(OCAMLCFLAGS) -o $@  -I +threads $(PKGS_CMA) threads.cma $^
%.opt: socket.cmxa lpd.cmxa %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -o $@ -I +threads \
	  $(PKGS_CMXA) threads.cmxa $^

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
.PHONY: dist
dist:
	mkdir $(PKGNAME)-$(PKGVERSION)
	cp -r $(DISTFILES) $(PKGNAME)-$(PKGVERSION)/
#	Create a trivial hosts.lpd
#	echo "# hosts.lpd\nmachine.network.com" \
#	  > $(PKGNAME)-$(PKGVERSION)/hosts.lpd
	tar --exclude "CVS" --exclude ".cvsignore" --exclude "*~" \
	  --exclude "*.cm{i,x,o,xa}" --exclude "*.o" \
	  -zcvf $(PKG_TARBALL) $(PKGNAME)-$(PKGVERSION)
	rm -rf $(PKGNAME)-$(PKGVERSION)

# Release a tarball and publish the HTML doc 
-include Makefile.pub


# Generic compilation instructions.

%.cmi: %.mli
	$(OCAMLC) $(OCAMLCFLAGS) -c $<

%.cmo: %.ml
	$(OCAMLC) $(OCAMLCFLAGS) -c $<

%.cma: %.ml %.cmi
	$(OCAMLC) -a -o $@ $(OCAMLCFLAGS) $<

%.cmx: %.ml
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

%.cmxa: %.ml %.cmi
	$(OCAMLOPT) -a -o $@ $(OCAMLOPTFLAGS) $<

.PHONY: dep depend
dep:    .depend
depend: .depend

.depend: $(wildcard *.mli) $(wildcard *.ml) $(wildcard */*.ml)
	ocamldep $^ > $@

ifeq ($(wildcard .depend),.depend)
include .depend
endif


.PHONY:clean
clean:
	rm -f *~ .*~ *.{o,a} *.cm[aiox] *.cmxa *.annot
	rm -rf $(DOC_DIR) $(PKG_TARBALL)
	find . -type f -perm -u=x -exec rm -f {} \;

.SUFFIXES: .ml .mli .cmi .cmo