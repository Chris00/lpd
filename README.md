LPD
===

`Lpd` is a Line Printer Daemon compliant with RFC 1179 written
entirely in OCaml. It allows to define your own actions for LPD
events.  An example of a spooler that prints jobs on win32 machines
(through [GSPRINT](http://www.cs.wisc.edu/%7Eghost/gsview/gsprint.htm)) is
provided.

For a complete description of the functions, see the interface
[Lpd](lpd.mli) (also available
[in HTML](http://lpd.forge.ocamlcore.org/doc/index.html)).

A small [Socket](socket.mli) module is included that defines
buffered fonctions on sockets that work even on platforms where
`in_channel_of_descr` does not work.  Some examples are also
included in these sources.


Install
-------

The easier way to install this library is by using
[opam](http://opam.ocaml.org/):

    opam install lpd

If you would like to compile the development version, you will need
the following packages:

- oasis — to set up the build with `ocamlbuild`;
- ocamlfind — to install the library;
- `make` — to provide an easy way to drive the build process.

Then issue:

    make
    make install

To remove the library, do

    make uninstall

