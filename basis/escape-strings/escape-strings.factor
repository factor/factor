! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs assocs.extras combinators kernel math math.order
math.statistics sequences sequences.extras sets ;
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
    [ escape-string ] map concat escape-string ;

: tag-payload ( str tag -- str' )
    [ escape-string ] dip prepend ;

: escape-simplest ( str -- str' )
    dup { char: \' char: \" char: \r char: \n char: \s } counts {
        { [ dup { char: \' char: \r char: \n char: \s } values-of sum 0 = ] [ drop "'" prepend ] }
        { [ dup char: \" of not ] [ drop "\"" "\"" surround ] }
        [ drop escape-string ]
    } cond ;
