! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit html.parser.utils
kernel make math namespaces quoting sequences sequences.parser
unicode ;
IN: html.parser

TUPLE: tag name attributes text closing? ;

SINGLETON: text
SINGLETON: dtd
SINGLETON: comment

<PRIVATE

SYMBOL: tagstack

: push-tag ( tag -- )
    tagstack get push ;

: closing-tag? ( string -- ? )
    [ f ]
    [ { [ first CHAR: / = ] [ last CHAR: / = ] } 1|| ] if-empty ;

: <tag> ( name attributes closing? -- tag )
    tag new
        swap >>closing?
        swap >>attributes
        swap >>name ;

: make-tag ( string attribs -- tag )
    [ [ closing-tag? ] keep "/" trim1 ] dip rot <tag> ;

: new-tag ( text name -- tag )
    tag new
        swap >>name
        swap >>text ; inline

: (read-quote) ( sequence-parser ch -- string )
    '[ [ current _ = ] take-until ] [ advance drop ] bi ;

: read-single-quote ( sequence-parser -- string )
    CHAR: ' (read-quote) ;

: read-double-quote ( sequence-parser -- string )
    CHAR: \" (read-quote) ;

: read-quote ( sequence-parser -- string )
    dup consume CHAR: ' =
    [ read-single-quote ] [ read-double-quote ] if ;

: read-key ( sequence-parser -- string )
    skip-whitespace
    [ current { [ CHAR: = = ] [ blank? ] } 1|| ] take-until ;

: read-token ( sequence-parser -- string )
    [ current blank? ] take-until ;

: read-value ( sequence-parser -- string )
    skip-whitespace
    dup current quote? [ read-quote ] [ read-token ] if
    [ blank? ] trim ;

: read-comment ( sequence-parser -- )
    [ "-->" take-until-sequence comment new-tag push-tag ]
    [ '[ _ advance drop ] 3 swap times ] bi ;

: read-dtd ( sequence-parser -- )
    [ ">" take-until-sequence dtd new-tag push-tag ]
    [ advance drop ] bi ;

: read-bang ( sequence-parser -- )
    advance dup { [ current CHAR: - = ] [ peek-next CHAR: - = ] } 1&&
    [ advance advance read-comment ] [ read-dtd ] if ;

: read-tag ( sequence-parser -- string )
    [
        [ current "><" member? ] take-until
        [ CHAR: / = ] trim-tail
    ] [ dup current CHAR: < = [ advance ] unless drop ] bi ;

: read-until-< ( sequence-parser -- string )
    [ current CHAR: < = ] take-until ;

: parse-text ( sequence-parser -- )
    read-until-< [ text new-tag push-tag ] unless-empty ;

: parse-key/value ( sequence-parser -- key value )
    [ read-key >lower ]
    [ skip-whitespace "=" take-sequence ]
    [ swap [ read-value ] [ drop dup ] if ] tri ;

: (parse-attributes) ( sequence-parser -- )
    skip-whitespace
    dup sequence-parse-end? [
        drop
    ] [
        [ parse-key/value swap ,, ] [ (parse-attributes) ] bi
    ] if ;

: parse-attributes ( sequence-parser -- hashtable )
    [ (parse-attributes) ] H{ } make ;

: (parse-tag) ( string -- string' hashtable )
    [
        [ read-token >lower ] [ parse-attributes ] bi
    ] parse-sequence ;

: read-< ( sequence-parser -- string/f )
    advance dup current [
        CHAR: ! = [ read-bang f ] [ read-tag ] if
    ] [
        drop f
    ] if* ;

: parse-tag ( sequence-parser -- )
    read-< [ (parse-tag) make-tag push-tag ] unless-empty ;

: (parse-html) ( sequence-parser -- )
    dup peek-next [
        [ parse-text ] [ parse-tag ] [ (parse-html) ] tri
    ] [ drop ] if ;

: tag-parse ( quot -- vector )
    V{ } clone tagstack [ parse-sequence ] with-variable ; inline

PRIVATE>

: parse-html ( string -- vector )
    [ (parse-html) tagstack get ] tag-parse ;
