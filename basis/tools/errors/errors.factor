! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs debugger io kernel sequences source-files.errors ;
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
