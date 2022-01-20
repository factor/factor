! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: command-line formatting io io.encodings
io.encodings.binary io.files kernel namespaces sequences ;

IN: tools.cat

: cat-stream ( -- )
    input-stream get binary re-decode
    output-stream get binary re-encode
    '[ _ stream-write ] each-stream-block ;

: cat-file ( path -- )
    dup file-exists? [
        binary [ cat-stream ] with-file-reader
    ] [ "%s: not found\n" printf flush ] if ;

: cat-files ( paths -- )
    [ dup "-" = [ drop cat-stream ] [ cat-file ] if ] each ;

: run-cat ( -- )
    command-line get [ cat-stream ] [ cat-files ] if-empty ;

MAIN: run-cat
