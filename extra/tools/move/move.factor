! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators command-line io io.directories io.files.info
kernel math namespaces sequences ;

IN: tools.move

! FIXME: better error messages when files don't exist

: usage ( -- )
    "Usage: move source ... target" print ;

: move-to-dir ( args -- )
    dup last file-info directory?
    [ unclip-last move-files-into ] [ drop usage ] if ;

: move-to-file ( args -- )
    dup last file-info directory?
    [ move-to-dir ] [ first2 move-file ] if ;

: run-move ( -- )
    command-line get dup length {
        { [ dup 2 > ] [ drop move-to-dir  ] }
        { [ dup 2 = ] [ drop move-to-file ] }
        [ 2drop usage ]
    } cond ;

MAIN: run-move
