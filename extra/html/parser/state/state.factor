! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces math kernel sequences accessors fry circular ;
IN: html.parser.state

TUPLE: state string i ;

: get-i ( -- i ) state get i>> ; inline

: get-char ( -- char )
    state get [ i>> ] [ string>> ] bi ?nth ; inline

: get-next ( -- char )
    state get [ i>> 1+ ] [ string>> ] bi ?nth ; inline

: next ( -- )
    state get [ 1+ ] change-i drop ; inline

: string-parse ( string quot -- )
    [ 0 state boa state ] dip with-variable ; inline

: short* ( n seq -- n' seq )
    over [ nip dup length swap ] unless ; inline

: skip-until ( quot: ( -- ? ) -- )
    get-char [
        [ call ] keep swap
        [ drop ] [ next skip-until ] if
    ] [ drop ] if ; inline recursive

: take-until ( quot: ( -- ? ) -- )
    get-i [ skip-until ] dip get-i
    state get string>> subseq ; inline

: string-matches? ( string circular -- ? )
    get-char over push-growing-circular sequence= ; inline

: take-string ( match -- string )
    dup length <growing-circular>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head next ; inline
