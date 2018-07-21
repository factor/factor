! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs assocs.extras combinators kernel math math.order
math.statistics sequences sequences.extras sets ;
IN: escape-strings

: find-escapes ( str -- set )
    [ HS{ } clone 0 0 ] dip
    [
        {
            { CHAR: ] [ 1 + dup 2 = [ drop over adjoin 0 1 ] when ] }
            { CHAR: = [ dup 1 = [ [ 1 + ] dip ] when ] }
            [ 3drop 0 0 ]
        } case
    ] each 0 > [ over adjoin ] [ drop ] if ;

: lowest-missing ( set -- min )
    members dup [ = not ] find-index
    [ nip ] [ drop length ] if ;

: escape-string* ( str n -- str' )
    CHAR: = <repetition>
    [ "[" dup surround ] [ "]" dup surround ] bi surround ;

: escape-string ( str -- str' )
    dup find-escapes lowest-missing escape-string* ;

: escape-strings ( strs -- str )
    [ escape-string ] map concat escape-string ;

: tag-payload ( str tag -- str' )
    [ escape-string ] dip prepend ;

: escape-simplest ( str -- str' )
    dup { CHAR: ' CHAR: " CHAR: \r CHAR: \n CHAR: \s } counts {
        { [ dup { CHAR: ' CHAR: \r CHAR: \n CHAR: \s } values-of sum 0 = ] [ drop "'" prepend ] }
        { [ dup CHAR: " of not ] [ drop "\"" "\"" surround ] }
        [ drop escape-string ]
    } cond ;