! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators combinators.short-circuit command-line io
io.directories io.files io.files.info kernel math namespaces
sequences ;

IN: tools.copy

: usage ( -- )
    "Usage: copy source ... target" print ;

: copy-to-dir ( args -- )
    dup last file-info directory?
    [ unclip-last copy-files-into ] [ drop usage ] if ;

: copy-to-file ( args -- )
    dup last { [ file-exists? ] [ file-info directory? ] } 1&&
    [ copy-to-dir ] [ first2 copy-file ] if ;

: run-copy ( -- )
    command-line get dup length {
        { [ dup 2 > ] [ drop copy-to-dir  ] }
        { [ dup 2 = ] [ drop copy-to-file ] }
        [ 2drop usage ]
    } cond ;

MAIN: run-copy
