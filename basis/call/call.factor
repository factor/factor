! Copyright (C) 2009 Daniel Ehrenberg, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private macros fry summary sequences
sequences.private accessors effects effects.parser parser words
make ;
IN: call

ERROR: wrong-values effect ;

M: wrong-values summary drop "Quotation called with stack effect" ;

<PRIVATE

: parse-call( ( accum word -- accum )
    [ ")" parse-effect parsed ] dip parsed ;

: call-effect-unsafe ( quot effect -- )
    drop call ;

: call-unsafe( \ call-effect-unsafe parse-call( ; parsing

PRIVATE>

: (call-effect>quot) ( in out effect -- quot )
    [
        [ [ datastack ] dip dip ] %
        [ [ , ] bi@ \ check-datastack , ] dip [ wrong-values ] curry , \ unless ,
    ] [ ] make ;

: call-effect>quot ( effect -- quot )
    [ in>> length ] [ out>> length ] [ ] tri
    [ (call-effect>quot) ] keep add-effect-input
    [ call-effect-unsafe ] 2curry ;

MACRO: call-effect ( effect -- quot )
    call-effect>quot ;

: call( \ call-effect parse-call( ; parsing

<PRIVATE

: execute-effect-unsafe ( word effect -- )
    drop execute ;

: execute-unsafe( \ execute-effect-unsafe parse-call( ; parsing

: execute-effect-slow ( word effect -- )
    [ [ execute ] curry ] dip call-effect ; inline

: cache-hit? ( word ic -- ? ) first-unsafe eq? ; inline

: cache-hit ( word effect ic -- ) drop execute-effect-unsafe ; inline

: execute-effect-unsafe? ( word effect -- ? )
    over optimized>> [ [ stack-effect ] dip effect<= ] [ 2drop f ] if ; inline

: cache-miss ( word effect ic -- )
    2over execute-effect-unsafe?
    [ [ nip set-first ] [ drop execute-effect-unsafe ] 3bi ]
    [ execute-effect-slow ] if ; inline

: execute-effect-ic ( word effect ic -- )
    #! ic is a mutable cell { effect }
    3dup nip cache-hit? [ cache-hit ] [ cache-miss ] if ; inline

: execute-effect>quot ( effect -- quot )
    { f } clone [ execute-effect-ic ] 2curry ;

PRIVATE>

MACRO: execute-effect ( effect -- )
    execute-effect>quot ;

: execute( \ execute-effect parse-call( ; parsing
