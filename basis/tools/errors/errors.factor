! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs debugger io kernel sequences source-files.errors
summary accessors continuations make math.parser io.styles namespaces ;
IN: tools.errors

#! Tools for source-files.errors. Used by tools.tests and others
#! for error reporting

M: source-file-error summary
    error>> summary ;

M: source-file-error compute-restarts
    error>> compute-restarts ;

M: source-file-error error-help
    error>> error-help ;

M: source-file-error error.
    [
        [
            [
                [ file>> [ % ": " % ] when* ]
                [ line#>> [ # "\n" % ] when* ] bi
            ] "" make
        ] [
            [
                presented set
                bold font-style set
            ] H{ } make-assoc
        ] bi format
    ] [ error>> error. ] bi ;

: errors. ( errors -- )
    group-by-source-file sort-errors
    [
        [ nl "==== " write print nl ]
        [ [ nl ] [ error. ] interleave ]
        bi*
    ] assoc-each ;
