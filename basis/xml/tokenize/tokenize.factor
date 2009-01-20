! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs combinators locals
combinators.short-circuit fry io.encodings io.encodings.iana
io.encodings.string io.encodings.utf16 io.encodings.utf8 kernel make
math math.parser namespaces sequences sets splitting xml.state-parser
strings xml.char-classes xml.data xml.entities xml.errors hashtables
circular ;
IN: xml.tokenize

! XML namespace processing: ns = namespace

! A stack of hashtables
SYMBOL: ns-stack

: attrs>ns ( attrs-alist -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            swap dup space>> "xmlns" =
            [ main>> set ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" set ] [ drop ] if
            ] if
        ] assoc-each
    ] { } make-assoc f like ;

: add-ns ( name -- )
    dup space>> dup ns-stack get assoc-stack
    [ nip ] [ nonexist-ns ] if* >>url drop ;

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
    [ dup add-ns ] dip dup [ drop add-ns ] assoc-each <attrs> ;

! Parsing names

! version=1.0? is calculated once and passed around for efficiency

: assure-name ( str version=1.0? -- str )
    over {
        [ first name-start? ]
        [ rest-slice [ name-char? ] with all? ]
    } 2&& [ bad-name ] unless ;

: (parse-name) ( start -- str )
    version=1.0?
    [ [ get-char name-char? not ] curry take-until append ]
    [ assure-name ] bi ;

: parse-name-starting ( start -- name )
    (parse-name) get-char CHAR: : =
    [ next "" (parse-name) ] [ "" swap ] if f <name> ;

: parse-name ( -- name )
    "" parse-name-starting ;

!   -- Parsing strings

: parse-named-entity ( string -- )
    dup entities at [ , ] [
        dup extra-entities get at
        [ % ] [ no-entity ] ?if
    ] ?if ;

: parse-entity ( -- )
    next CHAR: ; take-char next
    "#" ?head [
        "x" ?head 16 10 ? base> ,
    ] [ parse-named-entity ] if ;

:: (parse-char) ( quot: ( ch -- ? ) -- )
    get-char :> char
    {
        { [ char not ] [ ] }
        { [ char quot call ] [ next ] }
        { [ char CHAR: & = ] [ parse-entity quot (parse-char) ] }
        [ char , next quot (parse-char) ]
    } cond ; inline recursive

: parse-char ( quot: ( ch -- ? ) -- seq )
    [ (parse-char) ] "" make ; inline

: assure-no-]]> ( circular -- )
    "]]>" sequence= [ text-w/]]> ] when ;

: parse-text ( -- string )
    3 f <array> <circular> '[
        _ [ push-circular ]
        [ nip assure-no-]]> ]
        [ drop CHAR: < = ] 2tri
    ] parse-char ;

! Parsing tags

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: (parse-quote) ( <-disallowed? ch -- string )
    swap '[
        dup _ = [ drop t ]
        [ CHAR: < = _ and [ attr-w/< ] [ f ] if ] if
    ] parse-char get-char
    [ unclosed-quote ] unless ; inline

: parse-quote* ( <-disallowed? -- seq )
    pass-blank get-char dup "'\"" member?
    [ next (parse-quote) ] [ quoteless-attr ] if ; inline

: parse-quote ( -- seq )
   f parse-quote* ;

: normalize-quot ( str -- str )
    [ dup "\t\r\n" member? [ drop CHAR: \s ] when ] map ;

: parse-attr ( -- )
    parse-name CHAR: = expect
    t parse-quote* normalize-quot 2array , ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start?
    [ parse-attr (middle-tag) ] when ;

: assure-no-duplicates ( attrs-alist -- attrs-alist )
    H{ } clone 2dup '[ swap _ push-at ] assoc-each
    [ nip length 2 >= ] assoc-filter >alist
    [ first first2 duplicate-attr ] unless-empty ;

: middle-tag ( -- attrs-alist )
    ! f make will make a vector if it has any elements
    [ (middle-tag) ] f make pass-blank
    assure-no-duplicates ;

: end-tag ( name attrs-alist -- tag )
    tag-ns pass-blank get-char CHAR: / =
    [ pop-ns <contained> next ] [ <opener> ] if ;

: take-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: take-cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-string ;

: take-word ( -- string )
    [ get-char blank? ] take-until ;

: take-decl-contents ( -- first second )
    pass-blank take-word pass-blank ">" take-string ;

: take-element-decl ( -- element-decl )
    take-decl-contents <element-decl> ;

: take-attlist-decl ( -- doctype-decl )
    take-decl-contents <attlist-decl> ;

: take-until-one-of ( seps -- str sep )
    '[ get-char _ member? ] take-until get-char ;

: expect-> ( -- )
    pass-blank CHAR: > expect ;

: take-system-id ( -- system-id )
    parse-quote <system-id>
    expect-> ;

: take-public-id ( -- public-id )
    parse-quote parse-quote <public-id>
    expect-> ;

DEFER: direct

: (take-internal-subset) ( -- )
    pass-blank get-char {
        { CHAR: ] [ next ] }
        [ drop "<!" expect-string direct , (take-internal-subset) ]
    } case ;

: take-internal-subset ( -- seq )
    [ (take-internal-subset) ] { } make ;

: (take-external-id) ( token -- external-id )
    pass-blank {
        { "SYSTEM" [ take-system-id ] }
        { "PUBLIC" [ take-public-id ] }
        [ bad-external-id ]
    } case ;

: take-external-id ( -- external-id )
    take-word (take-external-id) ;

: only-blanks ( str -- )
    [ blank? ] all? [ bad-decl ] unless ;

: take-doctype-decl ( -- doctype-decl )
    pass-blank " >" take-until-one-of {
        { CHAR: \s [
            pass-blank get-char CHAR: [ = [
                next take-internal-subset f swap
                expect->
            ] [
                " >" take-until-one-of {
                    { CHAR: \s [ (take-external-id) ] }
                    { CHAR: > [ only-blanks f ] }
                } case f
            ] if
        ] }
        { CHAR: > [ f f ] }
    } case <doctype-decl> ;

: take-entity-def ( -- entity-name entity-def )
    take-word pass-blank get-char {
        { CHAR: ' [ parse-quote ] }
        { CHAR: " [ parse-quote ] }
        [ drop take-external-id ]
    } case ;

: associate-entity ( entity-name entity-def -- )
    swap extra-entities [ ?set-at ] change ;

: take-entity-decl ( -- entity-decl )
    pass-blank get-char {
        { CHAR: % [ next pass-blank take-entity-def ] }
        [ drop take-entity-def 2dup associate-entity ]
    } case
    expect-> <entity-decl> ;

: take-directive ( -- directive )
    take-word {
        { "ELEMENT" [ take-element-decl ] }
        { "ATTLIST" [ take-attlist-decl ] }
        { "DOCTYPE" [ take-doctype-decl ] }
        { "ENTITY" [ take-entity-decl ] }
        [ bad-directive ]
    } case ;

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
        [ not-yes/no ]
    } case ;

: assure-no-extra ( seq -- )
    [ first ] map {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } diff
    [ extra-attrs ] unless-empty ; 

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ bad-version ] unless ;

: prolog-version ( alist -- version )
    T{ name f "" "version" f } swap at
    [ good-version ] [ versionless-prolog ] if* ;

: prolog-encoding ( alist -- encoding )
    T{ name f "" "encoding" f } swap at "UTF-8" or ;

: prolog-standalone ( alist -- version )
    T{ name f "" "standalone" f } swap at
    [ yes/no>bool ] [ f ] if* ;

: prolog-attrs ( alist -- prolog )
    [ prolog-version ]
    [ prolog-encoding ]
    [ prolog-standalone ]
    tri <prolog> ;

SYMBOL: string-input?
: decode-input-if ( encoding -- )
    string-input? get [ drop ] [ decode-input ] if ;

: parse-prolog ( -- prolog )
    pass-blank middle-tag "?>" expect-string
    dup assure-no-extra prolog-attrs
    dup encoding>> dup "UTF-16" =
    [ drop ] [ name>encoding [ decode-input-if ] when* ] if
    dup prolog-data set ;

: instruct ( -- instruction )
    "" (parse-name) dup "xml" =
    [ drop parse-prolog ] [
        dup >lower "xml" =
        [ capitalized-prolog ]
        [ "?>" take-string append <instruction> ] if
    ] if ;

: make-tag ( -- tag )
    {
        { [ get-char dup CHAR: ! = ] [ drop next direct ] }
        { [ CHAR: ? = ] [ next instruct ] }
        [
            start-tag [ dup add-ns pop-ns <closer> ]
            [ middle-tag end-tag ] if
            CHAR: > expect
        ]
    } cond ;

! Autodetecting encodings

: continue-make-tag ( str -- tag )
    parse-name-starting middle-tag end-tag CHAR: > expect ;

: start-utf16le ( -- tag )
    utf16le decode-input-if
    CHAR: ? expect
    0 expect check instruct ;

: 10xxxxxx? ( ch -- ? )
    -6 shift 3 bitand 2 = ;
          
: start<name ( ch -- tag )
    ascii?
    [ utf8 decode-input-if next make-tag ] [
        next
        [ get-next 10xxxxxx? not ] take-until
        get-char suffix utf8 decode
        utf8 decode-input-if next
        continue-make-tag
    ] if ;
          
: start< ( -- tag )
    get-next {
        { 0 [ next next start-utf16le ] }
        { CHAR: ? [ check next next instruct ] } ! XML prolog parsing sets the encoding
        { CHAR: ! [ check utf8 decode-input next next direct ] }
        [ check start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-input
    CHAR: < expect check make-tag ;

: decode-expecting ( encoding string -- tag )
    [ decode-input-if next ] [ expect-string ] bi* check make-tag ;

: start-utf16be ( -- tag )
    utf16be "<" decode-expecting ;

: skip-utf16le-bom ( -- tag )
    utf16le "\u0000fe<" decode-expecting ;

: skip-utf16be-bom ( -- tag )
    utf16be "\u0000ff<" decode-expecting ;

: start-document ( -- tag )
    get-char {
        { CHAR: < [ start< ] }
        { 0 [ start-utf16be ] }
        { HEX: EF [ skip-utf8-bom ] }
        { HEX: FF [ skip-utf16le-bom ] }
        { HEX: FE [ skip-utf16be-bom ] }
        { f [ "" ] }
        [ drop utf8 decode-input-if f ]
        ! Same problem as with <e`>, in the case of XML chunks?
    } case check ;
