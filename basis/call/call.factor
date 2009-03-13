! Copyright (C) 2009 Daniel Ehrenberg, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel macros fry summary sequences sequences.private
generalizations accessors continuations effects effects.parser
parser words ;
IN: call

ERROR: wrong-values values quot length-required ;

M: wrong-values summary
    drop "Wrong number of values returned from quotation" ;

<PRIVATE

: firstn-safe ( array quot n -- ... )
    3dup nip swap length = [ nip firstn ] [ wrong-values ] if ; inline

: parse-call( ( accum word -- accum )
    [ ")" parse-effect parsed ] dip parsed ;

PRIVATE>

MACRO: call-effect ( effect -- quot )
    [ in>> length ] [ out>> length ] bi
    '[ [ _ narray ] dip [ with-datastack ] keep _ firstn-safe ] ;

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
    [ 2dup execute-effect-unsafe? ] dip
    '[ [ drop _ set-first ] [ execute-effect-unsafe ] 2bi ]
    [ execute-effect-slow ] if ; inline

: execute-effect-ic ( word effect ic -- )
    #! ic is a mutable cell { effect }
    3dup nip cache-hit? [ cache-hit ] [ cache-miss ] if ; inline

PRIVATE>

MACRO: execute-effect ( effect -- )
    { f } clone '[ _ _ execute-effect-ic ] ;

: execute( \ execute-effect parse-call( ; parsing
