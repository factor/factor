! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel macros fry summary sequences generalizations accessors
continuations effects effects.parser parser words ;
IN: call

ERROR: wrong-values values quot length-required ;

M: wrong-values summary
    drop "Wrong number of values returned from quotation" ;

<PRIVATE

: firstn-safe ( array quot n -- ... )
    3dup nip swap length = [ nip firstn ] [ wrong-values ] if ; inline

: execute-effect-unsafe ( word effect -- )
    drop execute ;

: execute-effect-unsafe? ( word effect -- ? )
    swap dup optimized>> [ stack-effect swap effect<= ] [ 2drop f ] if ; inline

: parse-call( ( accum word -- accum )
    [ ")" parse-effect parsed ] dip parsed ;

: execute-unsafe( \ execute-effect-unsafe parse-call( ; parsing

PRIVATE>

MACRO: call-effect ( effect -- quot )
    [ in>> length ] [ out>> length ] bi
    '[ [ _ narray ] dip [ with-datastack ] keep _ firstn-safe ] ;

: call( \ call-effect parse-call( ; parsing

: execute-effect ( word effect -- )
    2dup execute-effect-unsafe?
    [ execute-effect-unsafe ]
    [ [ [ execute ] curry ] dip call-effect ]
    if ; inline

: execute( \ execute-effect parse-call( ; parsing
