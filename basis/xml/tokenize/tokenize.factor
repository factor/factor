! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs combinators
combinators.short-circuit fry io.encodings io.encodings.iana
io.encodings.string io.encodings.utf16 io.encodings.utf8 kernel make
math math.parser namespaces sequences sets splitting state-parser
strings xml.char-classes xml.data xml.entities xml.errors ;
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

: version=1.0? ( -- ? )
    prolog-data get version>> "1.0" = ;

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

: (parse-entity) ( string -- )
    dup entities at [ , ] [ 
        prolog-data get standalone>>
        [ no-entity ] [
            dup extra-entities get at
            [ , ] [ no-entity ] ?if
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
        [ , next (parse-char) ]
    } cond ;

: parse-char ( ch -- string )
    [ (parse-char) ] "" make ;

: parse-quot ( ch -- string )
    parse-char get-char
    [ unclosed-quote ] unless ;

: parse-text ( -- string )
    CHAR: < parse-char ;
                                   
! Parsing tags

: start-tag ( -- name ? )
    #! Outputs the name and whether this is a closing tag
    get-char CHAR: / = dup [ next ] when
    parse-name swap ;

: parse-attr-value ( -- seq )
    get-char dup "'\"" member?
    [ next parse-quot ] [ quoteless-attr ] if ;

: parse-attr ( -- )
    [ parse-name ] with-scope
    pass-blank CHAR: = expect pass-blank
    [ parse-attr-value ] with-scope
    2array , ;

: (middle-tag) ( -- )
    pass-blank version=1.0? get-char name-start?
    [ parse-attr (middle-tag) ] when ;

: middle-tag ( -- attrs-alist )
    ! f make will make a vector if it has any elements
    [ (middle-tag) ] f make pass-blank ;

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

: take-element-decl ( -- element-decl )
    pass-blank " " take-string pass-blank ">" take-string <element-decl> ;

: take-attlist-decl ( -- doctype-decl )
    pass-blank " " take-string pass-blank ">" take-string <attlist-decl> ;

: take-until-one-of ( seps -- str sep )
    '[ get-char _ member? ] take-until get-char ;

: only-blanks ( str -- )
    [ blank? ] all? [ bad-doctype-decl ] unless ;

: take-system-literal ( -- str )
    pass-blank get-char next {
        { CHAR: ' [ "'" take-string ] }
        { CHAR: " [ "\"" take-string ] }
    } case ;

: take-system-id ( -- system-id )
    take-system-literal <system-id>
    ">" take-string only-blanks ;

: take-public-id ( -- public-id )
    take-system-literal
    take-system-literal <public-id>
    ">" take-string only-blanks ;

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
    " " take-string (take-external-id) ;

: take-doctype-decl ( -- doctype-decl )
    pass-blank " >" take-until-one-of {
        { CHAR: \s [
            pass-blank get-char CHAR: [ = [
                next take-internal-subset f swap
                ">" take-string only-blanks
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
    " " take-string pass-blank get-char {
        { CHAR: ' [ take-system-literal ] }
        { CHAR: " [ take-system-literal ] }
        [ drop take-external-id ]
    } case ;

: take-entity-decl ( -- entity-decl )
    pass-blank get-char {
        { CHAR: % [ next pass-blank take-entity-def ] }
        [ drop take-entity-def ]
    } case
    ">" take-string only-blanks <entity-decl> ;

: take-directive ( -- directive )
    " " take-string {
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

: prolog-attrs ( alist -- prolog )
    [ T{ name f "" "version" f } swap at
      [ good-version ] [ versionless-prolog ] if* ] keep
    [ T{ name f "" "encoding" f } swap at
      "UTF-8" or ] keep
    T{ name f "" "standalone" f } swap at
    [ yes/no>bool ] [ f ] if*
    <prolog> ;

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
    0 expect instruct ;

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
        { CHAR: ? [ next next instruct ] } ! XML prolog parsing sets the encoding
        { CHAR: ! [ utf8 decode-input next next direct ] }
        [ start<name ]
    } case ;

: skip-utf8-bom ( -- tag )
    "\u0000bb\u0000bf" expect utf8 decode-input
    CHAR: < expect make-tag ;

: start-utf16be ( -- tag )
    utf16be decode-input-if
    next CHAR: < expect make-tag ;

: skip-utf16le-bom ( -- tag )
    utf16le decode-input-if
    next HEX: FE expect
    CHAR: < expect make-tag ;

: skip-utf16be-bom ( -- tag )
    utf16be decode-input-if
    next HEX: FF expect
    CHAR: < expect make-tag ;

: start-document ( -- tag )
    get-char {
        { CHAR: < [ start< ] }
        { 0 [ start-utf16be ] }
        { HEX: EF [ skip-utf8-bom ] }
        { HEX: FF [ skip-utf16le-bom ] }
        { HEX: FE [ skip-utf16be-bom ] }
        { f [ "" ] }
        [ dup blank?
          [ drop pass-blank utf8 decode-input-if CHAR: < expect make-tag ]
          [ 1string ] if ! Replace with proper error?
        ]
    } case ;
