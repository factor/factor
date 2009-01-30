! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces xml.state kernel sequences accessors
xml.char-classes xml.errors math io sbufs fry strings ascii
circular xml.entities assocs make splitting math.parser
locals combinators arrays ;
IN: xml.tokenize

: assure-good-char ( ch -- ch )
    [
        version-1.0? over text? not get-check and
        [ disallowed-char ] when
    ] [ f ] if* ;

! * Basic utility words

: record ( char -- )
    CHAR: \n =
    [ 0 get-line 1+ set-line ] [ get-column 1+ ] if
    set-column ;

! (next) normalizes \r\n and \r
: (next) ( -- char )
    get-next read1
    2dup swap CHAR: \r = [
        CHAR: \n =
        [ nip read1 ] [ nip CHAR: \n swap ] if
    ] [ drop ] if
    set-next dup set-char assure-good-char ;

: next ( -- )
    #! Increment spot.
    get-char [ unexpected-end ] unless (next) record ;

: init-parser ( -- )
    0 1 0 f f t <spot> spot set
    read1 set-next next ;

: with-state ( stream quot -- )
    ! with-input-stream implicitly creates a new scope which we use
    swap [ init-parser call ] with-input-stream ; inline

: skip-until ( quot: ( -- ? ) -- )
    get-char [
        [ call ] keep swap [ drop ] [
            next skip-until
        ] if
    ] [ drop ] if ; inline recursive

: take-until ( quot -- string )
    #! Take the substring of a string starting at spot
    #! from code until the quotation given is true and
    #! advance spot to after the substring.
    10 <sbuf> [
        '[ @ [ t ] [ get-char _ push f ] if ] skip-until
    ] keep >string ; inline

: take-to ( seq -- string )
    '[ get-char _ member? ] take-until ;

: pass-blank ( -- )
    #! Advance code past any whitespace, including newlines
    [ get-char blank? not ] skip-until ;

: string-matches? ( string circular -- ? )
    get-char over push-circular
    sequence= ;

: take-string ( match -- string )
    dup length <circular-string>
    [ 2dup string-matches? ] take-until nip
    dup length rot length 1- - head
    get-char [ missing-close ] unless next ;

: expect ( string -- )
    dup [ get-char next ] replicate 2dup =
    [ 2drop ] [ expected ] if ;

! Suddenly XML-specific

: parse-named-entity ( string -- )
    dup entities at [ , ] [
        dup extra-entities get at
        [ % ] [ no-entity ] ?if
    ] ?if ;

: take-; ( -- string )
    next ";" take-to next ;

: parse-entity ( -- )
    take-; "#" ?head [
        "x" ?head 16 10 ? base> ,
    ] [ parse-named-entity ] if ;

: parse-pe ( -- )
    take-; dup pe-table get at
    [ % ] [ no-entity ] ?if ;

:: (parse-char) ( quot: ( ch -- ? ) -- )
    get-char :> char
    {
        { [ char not ] [ ] }
        { [ char quot call ] [ next ] }
        { [ char CHAR: & = ] [ parse-entity quot (parse-char) ] }
        { [ in-dtd? get char CHAR: % = and ] [ parse-pe quot (parse-char) ] }
        [ char , next quot (parse-char) ]
    } cond ; inline recursive

: parse-char ( quot: ( ch -- ? ) -- seq )
    [ (parse-char) ] "" make ; inline

: assure-no-]]> ( circular -- )
    "]]>" sequence= [ text-w/]]> ] when ;

:: parse-text ( -- string )
    3 f <array> <circular> :> circ
    depth get zero? :> no-text [| char |
        char circ push-circular
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

