! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel macros fry summary sequences generalizations accessors
continuations effects.parser parser words ;
IN: call

ERROR: wrong-values values quot length-required ;

M: wrong-values summary
    drop "Wrong number of values returned from quotation" ;

<PRIVATE

: firstn-safe ( array quot n -- ... )
    3dup nip swap length = [ nip firstn ] [ wrong-values ] if ; inline

PRIVATE>

MACRO: call-effect ( effect -- quot )
    [ in>> length ] [ out>> length ] bi
    '[ [ _ narray ] dip [ with-datastack ] keep _ firstn-safe ] ;

: call(
    ")" parse-effect parsed \ call-effect parsed ; parsing

: execute-effect ( word effect -- )
    [ [ execute ] curry ] dip call-effect ; inline

: execute(
    ")" parse-effect parsed \ execute-effect parsed ; parsing
