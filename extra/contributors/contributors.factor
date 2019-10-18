! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: memory io io.files io.styles io.launcher
sequences prettyprint kernel arrays xml xml.utilities system
hashtables sorting math.parser assocs ;
IN: contributors

: changelog ( -- xml )
    image parent-dir cd
    "darcs changes --xml-output" <process-stream> read-xml ;

: authors ( xml -- seq )
    children-tags [ "author" swap at ] map ;

: patch-count ( authors author -- n )
    [ = ] curry subset length ;

: patch-counts ( authors -- assoc )
    dup prune [ [ patch-count ] keep 2array ] curry* map ;

: contributors ( -- )
    changelog authors patch-counts sort-keys <reversed>
    standard-table-style [
        [
            [
                first2
                [ write ] with-cell
                [ number>string write ] with-cell
            ] with-row
        ] each
    ] tabular-output ;

MAIN: contributors
