! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs debugger io kernel sequences source-files.errors
summary accessors continuations make math.parser io.styles namespaces
compiler.errors ;
IN: tools.errors

#! Tools for source-files.errors. Used by tools.tests and others
#! for error reporting

M: source-file-error compute-restarts
    error>> compute-restarts ;

M: source-file-error error-help
    error>> error-help ;

CONSTANT: +listener-input+ "<Listener input>"

M: source-file-error summary
    [
        [ file>> [ % ": " % ] [ +listener-input+ % ] if* ]
        [ line#>> [ # ] when* ] bi
    ] "" make
    ;

M: source-file-error error.
    [ summary print nl ] [ error>> error. ] bi ;

: errors. ( errors -- )
    group-by-source-file sort-errors
    [
        [ nl "==== " write +listener-input+ or print nl ]
        [ [ nl ] [ error. ] interleave ]
        bi*
    ] assoc-each ;

: compiler-errors. ( type -- )
    errors-of-type values errors. ;

: :errors ( -- ) +compiler-error+ compiler-errors. ;

: :warnings ( -- ) +compiler-warning+ compiler-errors. ;

: :linkage ( -- ) +linkage-error+ compiler-errors. ;

M: not-compiled summary
    word>> name>> "The word " " cannot be executed because it failed to compile" surround ;

M: not-compiled error.
    [ summary print nl ] [ error>> error. ] bi ;