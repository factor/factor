! Copyright (C) 2017 John Benediktsson, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: ascii assocs checksums checksums.sha combinators
hex-strings kernel math math.functions math.parser
math.statistics ranges sequences sets sorting splitting strings
uuid ;
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

: find-number-escapes ( str -- set )
    [ HS{ } clone SBUF" " clone 0 ] dip
    [
        {
            { [ dup CHAR: ] = ] [
                drop 1 + dup 2 = [
                    drop dup >string pick adjoin
                    0 over set-length 1
                ] when
            ] }
            { [ dup digit? ] [ [ dup 1 = ] dip '[ [ _ over push ] dip ] [ ] if ] }
            [ 2drop 0 over set-length 0 ]
        } cond
    ] each 0 > [ [ >string over adjoin ] unless-empty ] [ drop ] if ;

: lowest-missing-number ( string-set -- n )
    members [
        0
    ] [
        [ string>number ] maximum-by string>number 1 +
    ] if-empty ;

: lowest-missing ( set -- min )
    members dup [ = not ] find-index
    [ nip ] [ drop length ] if ;

: surrounding-brackets ( delim -- open-delim close-delim )
    [ "[" 1surround ] [ "]" 1surround ] bi ;

: surround-by-brackets ( str delim -- str' )
    surrounding-brackets surround ;

: surround-by-equals-brackets ( str n -- str' )
    CHAR: = <repetition> surround-by-brackets ;

: escape-string ( str -- str' )
    dup find-escapes lowest-missing surround-by-equals-brackets ;

: escape-strings ( strs -- str )
    [ escape-string ] map concat escape-string ;

: number-escape-string* ( str -- str' n )
    dup find-number-escapes lowest-missing-number
    number>string [ surround-by-brackets ] keep ;

: number-escape-string ( str -- str' )
    number-escape-string* drop ;

: number-escape-strings ( strs -- str )
    [ number-escape-string ] map concat number-escape-string ;

: tag-payload ( str tag -- str' )
    [ escape-string ] dip prepend ;

: escape-simplest ( str -- str' )
    dup histogram {
        ! { [ dup { CHAR: ' CHAR: \r CHAR: \n CHAR: \s } values-of sum 0 = ] [ drop "'" prepend ] }
        { [ dup CHAR: " of not ] [ drop "\"" "\"" surround ] }
        [ drop escape-string ]
    } cond ;

: uuid1-escape-string ( str -- str' ) uuid1 surround-by-brackets ;
: uuid4-escape-string ( str -- str' ) uuid4 surround-by-brackets ;

: sha1-escape-string ( str -- str' )
    [ ] [ sha1 checksum-bytes bytes>hex-string ] bi surround-by-brackets ;

: sha256-escape-string ( str -- str' )
    [ ] [ sha-256 checksum-bytes bytes>hex-string ] bi surround-by-brackets ;

GENERIC: sha1-escape-strings ( obj -- strs )

M: sequence sha1-escape-strings ( seq -- strs )
    [ sha1-escape-string ] { } map-as ;

M: string sha1-escape-strings ( str -- strs )
    split-lines sha1-escape-strings ;
