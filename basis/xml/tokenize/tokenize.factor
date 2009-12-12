! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces xml.state kernel sequences accessors
xml.char-classes xml.errors math io sbufs fry strings ascii
circular xml.entities assocs splitting math.parser
locals combinators arrays hints ;
IN: xml.tokenize

! * Basic utility words

: assure-good-char ( spot ch -- )
    [
        swap
        [ version-1.0?>> over text? not ]
        [ check>> ] bi and [
            spot get [ 1 + ] change-column drop
            disallowed-char
        ] [ drop ] if
    ] [ drop ] if* ;

HINTS: assure-good-char { spot fixnum } ;

: record ( spot char -- spot )
    over char>> [
        CHAR: \n =
        [ [ 1 + ] change-line -1 ] [ dup column>> 1 + ] if
        >>column
    ] [ drop ] if ;

HINTS: record { spot fixnum } ;

:: (next) ( spot -- spot char )
    spot next>> :> old-next
    spot stream>> stream-read1 :> new-next
    old-next CHAR: \r = [
        spot CHAR: \n >>char
        new-next CHAR: \n =
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
    spot set
    read1 set-next next ;

: with-state ( stream quot -- )
    ! with-input-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-input-stream ; inline

:: (skip-until) ( quot: ( -- ? ) spot -- )
    spot char>> [
        quot call [
            spot next* quot spot (skip-until)
        ] unless
    ] when ; inline recursive

: skip-until ( quot: ( -- ? ) -- )
    spot get (skip-until) ; inline

: take-until ( quot -- string )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    10 <sbuf> [
        spot get swap
        '[ @ [ t ] [ _ char>> _ push f ] if ] skip-until
    ] keep >string ; inline

: take-to ( seq -- string )
    spot get swap '[ _ char>> _ member? ] take-until ;

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    spot get '[ _ char>> blank? not ] skip-until ;

: string-matches? ( string circular spot -- ? )
    char>> over circular-push sequence= ;

: take-string ( match -- string )
    dup length <circular-string>
    spot get '[ 2dup _ string-matches? ] take-until nip
    dup length rot length 1 - - head
    get-char [ missing-close ] unless next ;

: expect ( string -- )
    dup spot get '[ _ [ char>> ] keep next* ] replicate
    2dup = [ 2drop ] [ expected ] if ;

! Suddenly XML-specific

: parse-named-entity ( accum string -- )
    dup entities at [ swap push ] [
        dup extra-entities get at
        [ swap push-all ] [ no-entity ] ?if
    ] ?if ;

: take-; ( -- string )
    next ";" take-to next ;

: parse-entity ( accum -- )
    take-; "#" ?head [
        "x" ?head 16 10 ? base> swap push
    ] [ parse-named-entity ] if ;

: parse-pe ( accum -- )
    take-; dup pe-table get at
    [ swap push-all ] [ no-entity ] ?if ;

:: (parse-char) ( quot: ( ch -- ? ) accum spot -- )
    spot char>> :> char
    {
        { [ char not ] [ ] }
        { [ char quot call ] [ spot next* ] }
        { [ char CHAR: & = ] [
            accum parse-entity
            quot accum spot (parse-char)
        ] }
        { [ in-dtd? get char CHAR: % = and ] [
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
    1024 <sbuf> [ spot get (parse-char) ] keep >string ; inline

: assure-no-]]> ( circular -- )
    "]]>" sequence= [ text-w/]]> ] when ;

:: parse-text ( -- string )
    3 f <array> <circular> :> circ
    depth get zero? :> no-text [| char |
        char circ circular-push
        circ assure-no-]]>
        no-text [ char blank? char CHAR: < = or [
            char 1string t pre/post-content
        ] unless ] when
        char CHAR: < =
    ] parse-char ;

: close ( -- )
    pass-blank ">" expect ;

: normalize-quote ( str -- str )
    [ dup "\t\r\n" member? [ drop CHAR: \s ] when ] map ;

: (parse-quote) ( <-disallowed? ch -- string )
    swap '[
        dup _ = [ drop t ]
        [ CHAR: < = _ and [ attr-w/< ] [ f ] if ] if
    ] parse-char normalize-quote get-char
    [ unclosed-quote ] unless ; inline

: parse-quote* ( <-disallowed? -- seq )
    pass-blank get-char dup "'\"" member?
    [ next (parse-quote) ] [ quoteless-attr ] if ; inline

: parse-quote ( -- seq )
   f parse-quote* ;

