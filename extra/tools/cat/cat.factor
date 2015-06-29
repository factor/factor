! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line formatting kernel io io.encodings.binary
io.files namespaces sequences strings ;

IN: tools.cat

: cat-lines ( -- )
    [ print flush ] each-line ;

: cat-stream ( -- )
    [ >string write flush ] each-block ;

: cat-file ( path -- )
    dup exists? [
        binary [ cat-stream ] with-file-reader
    ] [ "%s: not found\n" printf flush ] if ;

: cat-files ( paths -- )
    [ dup "-" = [ drop cat-lines ] [ cat-file ] if ] each ;

: run-cat ( -- )
    command-line get [ cat-lines ] [ cat-files ] if-empty ;

MAIN: run-cat
