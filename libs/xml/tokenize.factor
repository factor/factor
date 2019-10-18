! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml-errors xml-data kernel state-parser kernel namespaces xml-utils
    errors strings math sequences hashtables char-classes arrays entities ;
IN: xml-tokenize

! -- Parsing names

: version=1.0? ( -- ? )
    prolog-data get prolog-version "1.0" = ;

! version=1.0? is calculated once and passed around for efficiency
: name-start-char? ( 1.0? char -- ? )
    swap [ 1.0name-start-char? ] [ 1.1name-start-char? ] if ;

: name-char? ( 1.0? char -- ? )
    swap [ 1.0name-char? ] [ 1.1name-char? ] if ;

: (parse-name) ( -- str )
    version=1.0? dup
    get-char name-start-char? [
        [ dup get-char name-char? not ] take-until nip
    ] [
        "Malformed name" <xml-string-error> throw
    ] if ;

: parse-name ( -- name )
    (parse-name) get-char CHAR: : =
    [ next (parse-name) ] [ "" swap ] if f <name> ;

!   -- Parsing strings

: (parse-entity) ( string -- )
    dup entities hash [ , ] [ 
        prolog-data get prolog-standalone
        [ <no-entity> throw ] [
            dup extra-entities get ?hash
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

! -- Parsing tags

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
    pass-blank version=1.0? get-char name-start-char?
    [ parse-attr (middle-tag) ] when ;

: middle-tag ( -- hash )
    [ (middle-tag) ] V{ } make pass-blank ;

: end-tag ( string hash -- tag )
    pass-blank get-char CHAR: / =
    [ <contained> next ] [ <opener> ] if ;

: skip-comment ( -- comment )
    "--" expect-string
    "--" take-string
    <comment>
    CHAR: > expect ;

: cdata ( -- string )
    "[CDATA[" expect-string "]]>" take-string next ;

: direct ( -- object )
    get-char {
        { [ dup CHAR: - = ] [ drop skip-comment ] }
        { [ CHAR: [ = ] [ cdata ] }
        { [ t ] [ CHAR: > take-char <directive> next ] }
    } cond ;

: yes/no>bool ( string -- t/f )
    dup "yes" = [ drop t ] [
        dup "no" = [ drop f ] [
            <not-yes/no> throw
        ] if
    ] if ;

: assure-no-extra ( seq -- )
    [ first ] map {
        T{ name f "" "version" f }
        T{ name f "" "encoding" f }
        T{ name f "" "standalone" f }
    } swap diff dup empty? [ drop ] [ <extra-attrs> throw ] if ; 

: good-version ( version -- version )
    dup { "1.0" "1.1" } member? [ <bad-version> throw ] unless ;

: prolog-attrs ( alist -- prolog )
    [ T{ name f "" "version" f } swap get-attr
      [ good-version ] [ <versionless-prolog> throw ] if* ] keep
    [ T{ name f "" "encoding" f } swap get-attr
      [ "iso-8859-1" ] unless* ] keep
    T{ name f "" "standalone" f } swap get-attr
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
        { [ start-tag ] [ <closer> CHAR: > expect  ] }
        { [ t ] [ middle-tag end-tag CHAR: > expect ] }
    } cond ;
