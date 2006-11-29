! Copyright (C) 2004, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions generic hashtables help tools io
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

: code-heap-start 17 getenv ;
: code-heap-end 18 getenv ;

: <xt-map> ( -- xtmap )
    [
        f code-heap-start 2array ,
	    all-words [ compiled? ] subset
	    [ dup word-xt 2array , ] each
        f  code-heap-end 2array ,
    ] { } make [ [ second ] 2apply - ] sort ;

: find-xt ( xt xtmap -- word )
    [ second - ] binsearch* first ;

: symbolic-stack-trace ( seq -- seq )
    <xt-map> swap [ dup pick find-xt 2array ] map nip ;

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
    "(offset " write word-xt - >hex write ")" write ;

: bare-xt. ( xt -- )
    "C code:   " write xt. ;

: :trace
    error-stack-trace get symbolic-stack-trace <reversed> [
        first2 [ word-xt. ] [ bare-xt. ] if* terpri
    ] each ;

: :c ( -- )
    error-continuation get continuation-call callstack. :trace ;

: :get ( variable -- value )
    error-continuation get continuation-name hash-stack ;

: :res ( n -- )
    restarts get-global nth
    f restarts set-global
    first3 continue-with ;

: :edit ( -- )
    error get delegates [ parse-error-file ] find nip [
        dup parse-error-file ?resource-path
        swap parse-error-line edit-location
    ] when* ;

: (:help-multi)
    "This error has multiple delegates:" print
    help-outliner terpri ;

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
