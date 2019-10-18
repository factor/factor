! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables help tools io
kernel kernel-internals math namespaces parser prettyprint
sequences sequences-internals strings styles vectors words ;
IN: errors

PREDICATE: array kernel-error ( obj -- ? )
    dup first \ kernel-error eq? swap second 0 18 between? and ;

GENERIC: error. ( error -- )
GENERIC: error-help ( error -- topic )

M: object error. . ;
M: object error-help drop f ;

M: tuple error. describe ;
M: tuple error-help class ;

M: string error. print ;

SYMBOL: restarts

: :s ( -- )
    error-continuation get continuation-data stack. ;

: :r ( -- )
    error-continuation get continuation-retain stack. ;

: :c ( -- )
    error-continuation get continuation-call callstack. ;

: :get ( variable -- value )
    error-continuation get continuation-name hash-stack ;

: :res ( n -- )
    restarts get nth first3 continue-with ;

: :edit ( -- )
    error get
    dup parse-error-file ?resource-path
    swap parse-error-line
    edit-location ;

: (:help-multi)
    "This error has multiple delegates:" print help-outliner ;

: (:help-none)
    drop "No help for this error. " print ;

: :help ( -- )
    error get delegates [ error-help ] map [ ] subset
    {
        { [ dup empty? ] [ (:help-none) ] }
        { [ dup length 1 = ] [ first help ] }
        { [ t ] [ (:help-multi) ] }
    } cond ;

: restart. ( restart n -- )
    [ [ # " :res  " % first % ] "" make ] keep
    [ :res ] curry print-quot ;

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
    ":help - documentation for this error" [ :help ] print-quot
    ":s    - data stack at exception time" [ :s ] print-quot
    ":r    - retain stack at exception time" [ :r ] print-quot
    ":c    - call stack at exception time" [ :c ] print-quot

    error get [ parse-error? ] is? [
        ":edit - jump to source location" [ :edit ] print-quot
    ] when

    ":get  ( var -- value ) accesses variables at time of the error" print
    flush ;

: print-error ( error -- )
    [
        dup error.
        restarts.
        debug-help
    ] [
        "Error in print-error!" print
    ] recover drop ;

: try ( quot -- ) [ print-error ] recover ;

: save-error ( error continuation -- )
    error-continuation set-global
    dup error set-global
    compute-restarts restarts set-global ;

: error-handler ( error -- )
    dup continuation save-error rethrow ;

: init-error-handler ( -- )
    V{ } clone set-catchstack
    ! kernel calls on error
    [ error-handler ] 5 setenv
    \ kernel-error 12 setenv ;
