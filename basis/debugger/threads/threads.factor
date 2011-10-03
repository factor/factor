! Copyright (C) 2008, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien debugger continuations threads
threads.private io io.styles prettyprint kernel make math.parser
namespaces ;
IN: debugger.threads

: error-in-thread. ( thread -- )
    "Error in thread " write
    [
        dup id>> #
        " (" % dup name>> %
        ", " % dup quot>> unparse-short % ")" %
    ] "" make swap write-object ":" print ;

: call-thread-error-handler? ( thread -- ? )
    initial-thread get-global eq?
    in-callback?
    or not ;

M: thread error-in-thread ( error thread -- )
    global [
        error-in-thread. nl
        print-error nl
        :c
        flush
    ] bind ;

[
    dup call-thread-error-handler?
    [ self error-in-thread stop ]
    [ [ die ] call( error thread -- * ) ] if
] thread-error-hook set-global
