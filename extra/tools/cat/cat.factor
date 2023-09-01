! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: command-line io io.encodings io.encodings.binary io.files
kernel namespaces sequences ;

IN: tools.cat

: cat-stream ( -- )
    input-stream get binary re-decode
    output-stream get binary re-encode
    '[ _ [ stream-write ] [ stream-flush ] bi ] each-stream-block ;

: cat-file ( path -- )
    [ binary [ cat-stream ] with-file-reader ]
    [ write ": not found" print flush ] if-file-exists ;

: cat-files ( paths -- )
    [ dup "-" = [ drop cat-stream ] [ cat-file ] if flush ] each ;

: run-cat ( -- )
    command-line get [ cat-stream ] [ cat-files ] if-empty ;

MAIN: run-cat
