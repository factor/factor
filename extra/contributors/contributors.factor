! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.launcher io.styles io hashtables kernel
sequences combinators.lib assocs system sorting math.parser ;
IN: contributors

: changelog ( -- authors )
    image parent-dir cd
    "git-log --pretty=format:%an" <process-stream> lines ;

: patch-counts ( authors -- assoc )
    dup prune
    [ dup rot [ = ] curry* count ] curry*
    { } map>assoc ;

: contributors ( -- )
    changelog patch-counts sort-values <reversed>
    standard-table-style [
        [
            [
                first2 swap
                [ write ] with-cell
                [ number>string write ] with-cell
            ] with-row
        ] each
    ] tabular-output ;

MAIN: contributors
