! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: ascii assocs combinators fry kernel math math.functions
math.parser math.ranges math.statistics sequences sets sorting
strings ;
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

: lowest-missing-number ( string-set -- min )
    members dup
    [ length ] histogram-by
    dup keys length [0,b]
    [ [ of ] keep over [ 10^ < ] [ nip ] if ] with find nip
    [ '[ length _ = ] filter natural-sort ] keep ! remove natural-sort here
    [
        [ drop "" ] [
            10^ <iota> [
                [ swap ?nth dup [ string>number ] when ] keep = not
            ] with find nip number>string
        ] if-zero
    ] keep char: 0 pad-head ;

: lowest-missing ( set -- min )
    members dup [ = not ] find-index
    [ nip ] [ drop length ] if ;

: surround-by-brackets ( str delim -- str' )
    [ "[" dup surround ] [ "]" dup surround ] bi surround ;

: surround-by-equals-brackets ( str n -- str' )
    char: = <repetition> surround-by-brackets ;

: escape-string ( str -- str' )
    dup find-escapes lowest-missing surround-by-equals-brackets ;

: escape-strings ( strs -- str )
    [ escape-string ] map concat escape-string ;

: number-escape-string ( str -- str' )
    dup find-number-escapes lowest-missing-number surround-by-brackets ;

: number-escape-strings ( strs -- str )
    [ number-escape-string ] map concat number-escape-string ;

: tag-payload ( str tag -- str' )
    [ escape-string ] dip prepend ;

: escape-simplest ( str -- str' )
    dup histogram {
        ! { [ dup { char: \' char: \r char: \n char: \s } values-of sum 0 = ] [ drop "'" prepend ] }
        { [ dup char: \" of not ] [ drop "\"" "\"" surround ] }
        [ drop escape-string ]
    } cond ;
