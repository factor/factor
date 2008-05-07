! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files io.launcher io.styles io.encodings.ascii io
hashtables kernel sequences sequences.lib assocs system sorting
math.parser sets ;
IN: contributors

: changelog ( -- authors )
    image parent-directory [
        "git-log --pretty=format:%an" ascii <process-reader> lines
    ] with-directory ;

: patch-counts ( authors -- assoc )
    dup prune
    [ dup rot [ = ] with count ] with
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
