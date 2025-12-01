! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors debugger continuations threads io io.styles
prettyprint kernel make math.parser namespaces ;
IN: debugger.threads

: error-in-thread. ( thread -- )
    "Error in thread " write
    [
        dup id>> #
        " (" % dup name>> %
        ", " % dup quot>> unparse-short % ")" %
    ] "" make swap write-object ":" print ;

M: linked-error error.
    [ thread>> error-in-thread. ] [ error>> error. ] bi ;

! ( error thread -- * )
[
    dup initial-thread get-global eq? [
        die drop rethrow
    ] [
        [
            error-in-thread. nl
            print-error nl
            :c
            flush
        ] with-global
        stop
    ] if
] thread-error-hook set-global
