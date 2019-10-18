! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables tools io
kernel math namespaces parser prettyprint sequences
sequences-internals strings styles vectors words errors ;
IN: kernel-internals

: save-error ( error trace continuation -- )
    error-continuation set-global
    error-stack-trace set-global
    dup error set-global
    compute-restarts restarts set-global ;

: error-handler ( error trace -- )
    dupd continuation save-error rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! kernel calls on error
    [ error-handler ] 5 setenv
    \ kernel-error 12 setenv ;

: find-xt ( xt xtmap -- word )
    [ second - ] binsearch* first ;

: symbolic-stack-trace ( seq -- seq )
    xt-map 2 group swap [ dup rot find-xt 2array ] map-with ;

IN: errors

GENERIC: error. ( error -- )
GENERIC: error-help ( error -- topic )

M: object error. . ;
M: object error-help drop f ;

M: tuple error. describe ;
M: tuple error-help class ;

M: string error. print ;

: :s ( -- )
    error-continuation get continuation-data stack. ;

: :r ( -- )
    error-continuation get continuation-retain stack. ;

: xt. ( xt -- )
    >hex cell 2 * CHAR: 0 pad-left write ;

: word-xt. ( xt word -- )
    "Compiled: " write dup pprint bl
    "(offset " write word-xt - >hex write ")" print ;

: :trace
    error-stack-trace get symbolic-stack-trace <reversed>
    [ first2 word-xt. ] each ;

: :c ( -- )
    error-continuation get continuation-call callstack. :trace ;

: :get ( variable -- value )
    error-continuation get continuation-name hash-stack ;

: :res ( n -- )
    restarts get-global nth f restarts set-global restart ;

: restart. ( restart n -- )
    [ # " :res  " % restart-name % ] "" make print ;

: restarts. ( -- )
    restarts get dup empty? [
        drop
    ] [
        terpri
        "The following restarts are available:" print
        terpri
        dup length [ restart. ] 2each
    ] if ;

: debug-help ( -- )
    terpri
    "Debugger commands:" print
    terpri
    ":help - documentation for this error" print
    ":s    - data stack at exception time" print
    ":r    - retain stack at exception time" print
    ":c    - call stack at exception time" print

    error get [ parse-error? ] is? [
        ":edit - jump to source location" print
    ] when

    ":get  ( var -- value ) accesses variables at time of the error" print
    flush ;

: print-error ( error -- )
    [
        dup error.
    ] [
        "Error in print-error!" print drop
    ] recover drop ;

SYMBOL: error-hook

[ print-error restarts. debug-help ] error-hook set-global

: try ( quot -- )
    [ error-hook get call ] recover ;
