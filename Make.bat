REM Compile the project under windows (without needing "make")

SET OCAMLC=ocamlc
SET OCAMLCFLAGS=-dtypes
SET LIBS=unix.cma -I +threads threads.cma
SET PGM=lpd_to_win

%OCAMLC% %OCAMLCFLAGS% -c socket.mli
%OCAMLC% %OCAMLCFLAGS% -c socket.ml
%OCAMLC% %OCAMLCFLAGS% -c lpd.mli
%OCAMLC% %OCAMLCFLAGS% -c lpd.ml
%OCAMLC% %OCAMLCFLAGS% -o %PGM%.exe %LIBS% socket.cmo lpd.cmo %PGM%.ml
