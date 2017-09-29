! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators kernel math math.order math.statistics
sequences sequences.extras sets ;
IN: escape-strings

: find-escapes ( str -- set )
    [ HS{ } clone 0 0 ] dip
    [
        {
            { char: \] [ 1 + dup 2 = [ drop over adjoin 0 1 ] when ] }
            { char: = [ dup 1 = [ [ 1 + ] dip ] when ] }
            [ 3drop 0 0 ]
        } case
    ] each 0 > [ over adjoin ] [ drop ] if ;

: lowest-missing ( set -- min )
    members dup [ = not ] find-index
    [ nip ] [ drop length ] if ;

: escape-string* ( str n -- str' )
    char: = <repetition>
    [ "[" dup surround ] [ "]" dup surround ] bi surround ;

: escape-string ( str -- str' )
    dup find-escapes lowest-missing escape-string* ;

: escape-strings ( strs -- str )
    dup [ find-escapes ] map
    [
        [ lowest-missing ] map
        [ escape-string* ] 2map concat
    ] [
        [ ] [ union ] map-reduce
    ] bi
    dup cardinality 0 = [
        drop 1
    ] [
        members minmax nip 2 +
    ] if
    escape-string* ;
