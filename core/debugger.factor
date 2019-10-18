! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables inspector io
kernel math namespaces parser prettyprint sequences assocs
sequences-internals strings styles vectors words errors ;
IN: kernel-internals

: error-handler ( error trace -- )
    error-stack-trace set-global
    continuation error-continuation set-global
    save-error
    error get rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! kernel calls on error
    [ error-handler ] 5 setenv
    \ kernel-error 12 setenv ;

: find-xt ( xt xtmap -- word )
    [ second - ] binsearch* first ;

: symbolic-stack-trace ( -- newseq )
    error-stack-trace get
    xt-map 2 group swap [ swap find-xt ] map-with ;

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

: :c ( -- )
    error-continuation get continuation-call callstack.
    symbolic-stack-trace <reversed> stack. ;

: :get ( variable -- value )
    error-continuation get continuation-name assoc-stack ;

: :res ( n -- )
    restarts get-global nth f restarts set-global restart ;

: restart. ( restart n -- )
    [ # " :res  " % restart-name % ] "" make print ;

: restarts. ( -- )
    restarts get dup empty? [
        drop
    ] [
        nl
        "The following restarts are available:" print
        nl
        dup length [ restart. ] 2each
    ] if ;

: debug-help ( -- )
    nl
    "Debugger commands:" print
    nl
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
