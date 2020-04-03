! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii assocs combinators kernel math math.order
math.statistics sequences sets strings ;
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

: find-number-escapes ( str -- set )
    [ HS{ } clone sbuf"" clone 0 ] dip
    [
        {
            { [ dup char: \] = ] [
                drop 1 + dup 2 = [
                    drop dup >string pick adjoin
                    0 over set-length 1
                ] when
            ] }
            { [ dup digit? ] [ [ dup 1 = ] dip '[ [ _ over push ] dip ] [ ] if ] }
            [ 2drop 0 over set-length 0 ]
        } cond
    ] each 0 > [ >string over adjoin ] [ drop ] if ;

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
    dup histogram {
        ! { [ dup { char: \' char: \r char: \n char: \s } values-of sum 0 = ] [ drop "'" prepend ] }
        { [ dup char: \" of not ] [ drop "\"" "\"" surround ] }
        [ drop escape-string ]
    } cond ;
