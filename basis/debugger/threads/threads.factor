! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors debugger continuations threads threads.private
io io.styles prettyprint kernel math.parser namespaces make ;
IN: debugger.threads

: error-in-thread. ( thread -- )
    "Error in thread " write
    [
        dup id>> #
        " (" % dup name>> %
        ", " % dup quot>> unparse-short % ")" %
    ] "" make swap write-object ":" print ;

M: thread error-in-thread ( error thread -- )
    initial-thread get-global eq? [
        die drop
    ] [
        global [
            error-thread get-global error-in-thread. nl
            print-error nl
            :c
            flush
        ] bind
    ] if ;

[ self error-in-thread stop ]
thread-error-hook set-global
