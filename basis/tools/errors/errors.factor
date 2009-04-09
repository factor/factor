! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs compiler.errors debugger io kernel sequences
source-files.errors ;
IN: tools.errors

#! Tools for source-files.errors. Used by tools.tests and others
#! for error reporting

: errors. ( errors -- )
    group-by-source-file sort-errors
    [
        [ nl "==== " write print nl ]
        [ [ nl ] [ error. ] interleave ]
        bi*
    ] assoc-each ;

: compiler-errors. ( type -- )
    errors-of-type errors. ;

: :errors ( -- ) +error+ compiler-errors. ;

: :warnings ( -- ) +warning+ compiler-errors. ;

: :linkage ( -- ) +linkage+ compiler-errors. ;
