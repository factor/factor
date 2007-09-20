! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml.errors xml.data xml.utilities xml.char-classes
xml.entities kernel state-parser kernel namespaces strings math
math.parser sequences assocs arrays splitting combinators ;
IN: xml.tokenize

! XML namespace processing: ns = namespace

! A stack of hashtables
SYMBOL: ns-stack

: attrs>ns ( attrs-alist -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            swap dup name-space "xmlns" =
            [ name-tag set ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" set ] [ drop ] if
            ] if
        ] assoc-each
    ] { } make-assoc f like ;

: add-ns ( name -- )
    dup name-space dup ns-stack get assoc-stack
    [ nip ] [ <nonexist-ns> throw ] if* swap set-name-url ;

: push-ns ( hash -- )
    ns-stack get push ;

: pop-ns ( -- )
    ns-stack get pop* ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "http://www.w3.org/XML/1998/namespace" }
        { "xmlns" "http://www.w3.org/2000/xmlns" }
        { "" "" }
    } } clone
    ns-stack set ;

: tag-ns ( name attrs-alist -- name attrs )
    dup attrs>ns push-ns
    >r dup add-ns r> dup [ drop add-ns ] assoc-each <attrs> ;

! Parsing names

: version=1.0? ( -- ? )
    prolog-data get prolog-version "1.0" = ;

! version=1.0? is calculated once and passed around for efficiency

: (parse-name) ( -- str )
    version=1.0? dup
    get-char name-start? [
        [ dup get-char name-char? not ] take-until nip
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- name )
    (parse-name) get-char CHAR: : =
    [ next (parse-name) ] [ "" swap ] if f <name> ;

!   -- Parsing strings

: (parse-entity) ( string -- )
    dup entities at [ , ] [ 
        prolog-data get prolog-standalone
        [ <no-entity> throw ] [
            dup extra-entities get at
            [ , ] [ <no-entity> throw ] ?if
        ] if
    ] ?if ;

: parse-entity ( -- )
    next CHAR: ; take-char next
    "#" ?head [
        "x" ?head 16 10 ? base> ,
    ] [ (parse-entity) ] if ;

: (parse-char) ( ch -- )
    get-char {
        { [ dup not ] [ 2drop ] }
        { [ 2dup = ] [ 2drop next ] }
        { [ dup CHAR: & = ] [ drop parse-entity (parse-char) ] }
        { [ t ] [ , next (parse-char) ] }
    } cond ;

: parse-char ( ch -- string )
    [ (parse-char) ] "" make ;

: parse-quot ( ch -- string )
    parse-char get-char
    [ "XML file ends in a quote" <xml-string-error> throw ] unless ;

: parse-text ( -- string )
    CHAR: < parse-char ;

! Parsing tags

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: parse-attr-value ( -- seq )
    get-char dup "'\"" member? [
        next parse-quot
    ] [
        "Attribute lacks quote" <xml-string-error> throw
    ] if ;

: parse-attr ( -- )
    [ parse-name ] with-scope
    pass-blank CHAR: = expect pass-blank
    [ parse-attr-value ] with-scope
    2array , ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start?
    [ parse-attr (middle-tag) ] when ;

: middle-tag ( -- attrs-alist )
    [ (middle-tag) ] V{ } make pass-blank ;

: end-tag ( name attrs-alist -- tag )
    tag-ns pass-blank get-char CHAR: / =
    [ pop-ns <contained> next ] [ <opener> ] if ;

: take-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: take-cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-string next ;

: take-directive ( -- directive )
    CHAR: > take-char <directive> next ;

: direct ( -- object )
    get-char {
        { CHAR: - [ take-comment ] }
        { CHAR: [ [ take-cdata ] }
        [ drop take-directive ]
    } case ;

: yes/no>bool ( string -- t/f )
    {
        { "yes" [ t ] }
        { "no" [ f ] }
        [ <not-yes/no> throw ]
    } case ;

: assure-no-extra ( seq -- )
    [ first ] map {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } swap seq-diff
    dup empty? [ drop ] [ <extra-attrs> throw ] if ; 

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ <bad-version> throw ] unless ;

: prolog-attrs ( alist -- prolog )
    [ T{ name f "" "version" f } swap at
      [ good-version ] [ <versionless-prolog> throw ] if* ] keep
    [ T{ name f "" "encoding" f } swap at
      "iso-8859-1" or ] keep
    T{ name f "" "standalone" f } swap at
    [ yes/no>bool ] [ f ] if*
    <prolog> ;

: parse-prolog ( -- prolog )
    pass-blank middle-tag "?>" expect-string
    dup assure-no-extra prolog-attrs
    dup prolog-data set ;

: instruct ( -- instruction )
    (parse-name) dup "xml" =
    [ drop parse-prolog ] [
        dup >lower "xml" =
        [ <capitalized-prolog> throw ]
        [ "?>" take-string append <instruction> ] if
    ] if ;

: make-tag ( -- tag )
    {
        { [ get-char dup CHAR: ! = ] [ drop next direct ] }
        { [ CHAR: ? = ] [ next instruct ] } 
        { [ t ] [
            start-tag [ dup add-ns pop-ns <closer> ]
            [ middle-tag end-tag ] if
            CHAR: > expect
        ] }
    } cond ;
