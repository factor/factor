! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators
combinators.short-circuit hints io kernel math math.parser
namespaces sbufs sequences splitting strings xml.char-classes
xml.entities xml.errors xml.state ;
IN: xml.tokenize

! * Basic utility words

: assure-good-char ( spot ch -- )
    [
        over {
            [ version-1.0?>> over text? not ]
            [ check>> ]
        } 1&&
        [
            [ [ 1 + ] change-column drop ] dip
            disallowed-char
        ] [ 2drop ] if
    ] [ drop ] if* ;

HINTS: assure-good-char { spot fixnum } ;

: record ( spot char -- spot )
    over char>> [
        CHAR: \n eq?
        [ [ 1 + ] change-line -1 ] [ dup column>> 1 + ] if
        >>column
    ] [ drop ] if ;

HINTS: record { spot fixnum } ;

:: (next) ( spot -- spot char )
    spot next>> :> old-next
    spot stream>> stream-read1 :> new-next
    old-next CHAR: \r eq? [
        spot CHAR: \n >>char
        new-next CHAR: \n eq?
        [ spot stream>> stream-read1 >>next ]
        [ new-next >>next ] if
    ] [ spot old-next >>char new-next >>next ] if
    spot next>> ; inline

: next* ( spot -- )
    dup char>> [ unexpected-end ] unless
    (next) [ record ] keep assure-good-char ;

HINTS: next* { spot } ;

: next ( -- )
    spot get next* ;

: init-parser ( -- )
    0 1 0 0 f t f <spot>
        input-stream get >>stream
        read1 >>next
    spot set next ;

: with-state ( stream quot -- )
    ! with-input-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-input-stream ; inline

:: (skip-until) ( ... quot: ( ... char -- ... ? ) spot -- ... )
    spot char>> [
        quot call [
            spot next* quot spot (skip-until)
        ] unless
    ] when* ; inline recursive

: skip-until ( ... quot: ( ... char -- ... ? ) -- ... )
    spot get (skip-until) ; inline

: take-until ( ... quot: ( ... char -- ... ? ) -- ... string )
    ! Take the substring of a string starting at spot
    ! from code until the quotation given is true and
    ! advance spot to after the substring.
    10 <sbuf> [
        '[ _ keep over [ drop ] [ _ push ] if ] skip-until
    ] keep "" like ; inline

: take-to ( seq -- string )
    '[ _ member? ] take-until ; inline

: pass-blank ( -- )
    ! Advance code past any whitespace, including newlines
    [ blank? not ] skip-until ;

: next-matching ( pos ch str -- pos' )
    overd nth eq? [ 1 + ] [ drop 0 ] if ; inline

: string-matcher ( str -- quot: ( pos char -- pos ? ) )
    dup length 1 - '[ _ next-matching dup _ > ] ; inline

:: (take-string) ( match spot -- sbuf matched? )
    10 <sbuf> f [
        spot char>> [
            nip over push
            spot next*
            dup match tail? dup not
        ] [ f ] if*
    ] loop ; inline

: take-string ( match -- string )
    [ spot get (take-string) [ missing-close ] unless ]
    [ dupd 2length - over shorten "" like ] bi ;

: expect ( string -- )
    dup length spot get '[ _ [ char>> ] keep next* ] "" replicate-as
    2dup = [ 2drop ] [ expected ] if ;

! Suddenly XML-specific

: parse-named-entity ( accum string -- )
    [ entities at ]
    [ swap push ]
    [
        [ extra-entities get at ]
        [ swap push-all ] [ no-entity ] ?if
    ] ?if ;

: take-; ( -- string )
    next ";" take-to next ;

: parse-entity ( accum -- )
    take-; "#" ?head [
        "x" ?head 16 10 ? base> swap push
    ] [ parse-named-entity ] if ;

: parse-pe ( accum -- )
    take-;
    [ pe-table get at ]
    [ swap push-all ] [ no-entity ] ?if ;

:: (parse-char) ( quot: ( ch -- ? ) accum spot -- )
    spot char>> :> char
    {
        { [ char not ] [ ] }
        { [ char quot call ] [ spot next* ] }
        { [ char CHAR: & eq? ] [
            accum parse-entity
            quot accum spot (parse-char)
        ] }
        { [ char CHAR: % eq? [ in-dtd? get ] [ f ] if ] [
            accum parse-pe
            quot accum spot (parse-char)
        ] }
        [
            char accum push
            spot next*
            quot accum spot (parse-char)
        ]
    } cond ; inline recursive

: parse-char ( quot: ( ch -- ? ) -- seq )
    512 <sbuf> [ spot get (parse-char) ] keep "" like ; inline

: assure-no-]]> ( pos char -- pos' )
    "]]>" next-matching dup 2 > [ text-w/]]> ] when ; inline

:: parse-text ( -- string )
    depth get zero? :> no-text
    0 :> pos!
    [| char |
        pos char assure-no-]]> pos!
        no-text [
            char blank? char CHAR: < eq? or [
                char 1string t pre/post-content
            ] unless
        ] when
        char CHAR: < eq?
    ] parse-char ;

: close ( -- )
    pass-blank ">" expect ;

: normalize-quote ( str -- str )
    [ dup "\t\r\n" member? [ drop CHAR: \s ] when ] map! ;

: (parse-quote) ( <-disallowed? ch -- string )
    swap '[
        dup _ eq? [ drop t ]
        [ CHAR: < eq? _ and [ attr-w/< ] [ f ] if ] if
    ] parse-char normalize-quote get-char
    [ unclosed-quote ] unless ; inline

: parse-quote* ( <-disallowed? -- seq )
    pass-blank get-char dup "'\"" member?
    [ next (parse-quote) ] [ quoteless-attr ] if ; inline

: parse-quote ( -- seq )
    f parse-quote* ;
