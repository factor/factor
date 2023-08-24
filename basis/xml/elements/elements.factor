! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs combinators kernel make math namespaces
sequences sets strings unicode xml.char-classes xml.data xml.dtd
xml.errors xml.name xml.state xml.tokenize ;
IN: xml.elements

: take-interpolated ( quot -- interpolated )
    interpolating? get [
        drop get-char CHAR: > eq?
        [ next f ]
        [ "->" take-string [ blank? ] trim ]
        if <interpolated>
    ] [ call ] if ; inline

: interpolate-quote ( -- interpolated )
    [ quoteless-attr ] take-interpolated ;

: start-tag ( -- name ? )
    ! Outputs the name and whether this is a closing tag
    get-char CHAR: / eq? dup [ next ] when
    parse-name swap ;

: assure-no-duplicates ( attrs-alist -- attrs-alist )
    H{ } clone 2dup '[ swap _ push-at ] assoc-each
    [ nip length 2 >= ] { } assoc-filter-as
    [ first first2 duplicate-attr ] unless-empty ;

: parse-attr ( -- array )
    parse-name pass-blank "=" expect pass-blank
    get-char CHAR: < eq?
    [ "<-" expect interpolate-quote ]
    [ t parse-quote* ] if 2array ;

: middle-tag ( -- attrs-alist )
    ! f produce-as will make a vector if it has any elements
    [ pass-blank version-1.0? get-char name-start? ]
    [ parse-attr ] f produce-as pass-blank
    dup length 1 > [ assure-no-duplicates ] when ;

: end-tag ( name attrs-alist -- tag )
    tag-ns pass-blank get-char CHAR: / eq?
    [ pop-ns <contained> next ">" expect ]
    [ depth inc <opener> close ] if ;

: take-comment ( -- comment )
    "--" expect
    "--" take-string
    <comment>
    ">" expect ;

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
    T{ name { space "" } { main "version" } } of
    [ good-version ] [ versionless-prolog ] if*
    dup set-version ;

: prolog-encoding ( alist -- encoding )
    T{ name { space "" } { main "encoding" } } of
    "UTF-8" or ;

: yes/no>bool ( string -- t/f )
    {
        { "yes" [ t ] }
        { "no" [ f ] }
        [ not-yes/no ]
    } case ;

: prolog-standalone ( alist -- version )
    T{ name { space "" } { main "standalone" } } of
    [ yes/no>bool ] [ f ] if* ;

: prolog-attrs ( alist -- prolog )
    [ prolog-version ]
    [ prolog-encoding ]
    [ prolog-standalone ]
    tri <prolog> ;

: parse-prolog ( -- prolog )
    pass-blank middle-tag "?>" expect
    dup assure-no-extra prolog-attrs ;

: instruct ( -- instruction )
    take-name {
        { [ dup "xml" = ] [ drop parse-prolog ] }
        { [ dup >lower "xml" = ] [ capitalized-prolog ] }
        { [ dup valid-name? not ] [ bad-name ] }
        [ "?>" take-string append <instruction> ]
    } cond ;

: take-cdata ( -- cdata )
    depth get zero? [ bad-cdata ] when
    "[CDATA[" expect "]]>" take-string <cdata> ;

DEFER: make-tag ! Is this unavoidable?

: expand-pe ( -- ) ; ! Make this run the contents of the pe within a DOCTYPE

: dtd-loop ( -- )
    pass-blank get-char {
        { CHAR: ] [ next ] }
        { CHAR: % [ expand-pe ] }
        { CHAR: < [
            next make-tag dup dtd-acceptable?
            [ bad-doctype ] unless , dtd-loop
        ] }
        { f [ ] }
        [ 1string bad-doctype ]
    } case ;

: take-internal-subset ( -- dtd )
    [
        H{ } clone pe-table namespaces:set
        t in-dtd? namespaces:set
        dtd-loop
        pe-table get
    ] { } make swap extra-entities get swap <dtd> ;

: take-optional-id ( -- id/f )
    get-char "SP" member?
    [ take-external-id ] [ f ] if ;

: take-internal ( -- dtd/f )
    get-char CHAR: [ eq?
    [ next take-internal-subset ] [ f ] if ;

: take-doctype-decl ( -- doctype-decl )
    pass-blank take-name
    pass-blank take-optional-id
    pass-blank take-internal
    <doctype-decl> close ;

: take-directive ( -- doctype )
    take-name dup "DOCTYPE" =
    [ drop take-doctype-decl ] [
        in-dtd? get
        [ take-inner-directive ]
        [ misplaced-directive ] if
    ] if ;

: direct ( -- object )
    get-char {
        { CHAR: - [ take-comment ] }
        { CHAR: [ [ take-cdata ] }
        [ drop take-directive ]
    } case ;

: normal-tag ( -- tag )
    start-tag
    [ dup add-ns pop-ns <closer> depth dec close ]
    [ middle-tag end-tag ] if ;

: interpolate-tag ( -- interpolated )
    [ "-" bad-name ] take-interpolated ;

: make-tag ( -- tag )
    get-char {
        { CHAR: ! [ next direct ] }
        { CHAR: ? [ next instruct ] }
        { CHAR: - [ next interpolate-tag ] }
        [ drop normal-tag ]
    } case ;
