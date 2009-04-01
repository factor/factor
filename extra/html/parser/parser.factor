! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables html.parser.state
html.parser.utils kernel namespaces sequences
unicode.case unicode.categories combinators.short-circuit
quoting fry ;
IN: html.parser

TUPLE: tag name attributes text closing? ;

SINGLETON: text
SINGLETON: dtd
SINGLETON: comment
SYMBOL: tagstack

: push-tag ( tag -- )
    tagstack get push ;

: closing-tag? ( string -- ? )
    [ f ]
    [ { [ first CHAR: / = ] [ peek CHAR: / = ] } 1|| ] if-empty ;

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

: (read-quote) ( state-parser ch -- string )
    '[ [ current _ = ] take-until ] [ next drop ] bi ;

: read-single-quote ( state-parser -- string )
    CHAR: ' (read-quote) ;

: read-double-quote ( state-parser -- string )
    CHAR: " (read-quote) ;

: read-quote ( state-parser -- string )
    dup get+increment CHAR: ' =
    [ read-single-quote ] [ read-double-quote ] if ;

: read-key ( state-parser -- string )
    skip-whitespace
    [ current { [ CHAR: = = ] [ blank? ] } 1|| ] take-until ;

: read-token ( state-parser -- string )
    [ current blank? ] take-until ;

: read-value ( state-parser -- string )
    skip-whitespace
    dup current quote? [ read-quote ] [ read-token ] if
    [ blank? ] trim ;

: read-comment ( state-parser -- )
    "-->" take-until-sequence comment new-tag push-tag ;

: read-dtd ( state-parser -- )
    ">" take-until-sequence dtd new-tag push-tag ;

: read-bang ( state-parser -- )
    next dup { [ current CHAR: - = ] [ peek-next CHAR: - = ] } 1&&
    [ next next read-comment ] [ read-dtd ] if ;

: read-tag ( state-parser -- string )
    [ [ current "><" member? ] take-until ]
    [ dup current CHAR: < = [ next ] unless drop ] bi ;

: read-until-< ( state-parser -- string )
    [ current CHAR: < = ] take-until ;

: parse-text ( state-parser -- )
    read-until-< [ text new-tag push-tag ] unless-empty ;

: parse-key/value ( state-parser -- key value )
    [ read-key >lower ]
    [ skip-whitespace "=" take-sequence ]
    [ swap [ read-value ] [ drop f ] if ] tri ;

: (parse-attributes) ( state-parser -- )
    skip-whitespace
    dup state-parse-end? [
        drop
    ] [
        [ parse-key/value swap set ] [ (parse-attributes) ] bi
    ] if ;

: parse-attributes ( state-parser -- hashtable )
    [ (parse-attributes) ] H{ } make-assoc ;

: (parse-tag) ( string -- string' hashtable )
    [
        [ read-token >lower ] [ parse-attributes ] bi
    ] state-parse ;

: read-< ( state-parser -- string/f )
    next dup current [
        CHAR: ! = [ read-bang f ] [ read-tag ] if
    ] [
        drop f
    ] if* ;

: parse-tag ( state-parser -- )
    read-< [ (parse-tag) make-tag push-tag ] unless-empty ;

: (parse-html) ( state-parser -- )
    dup peek-next [
        [ parse-text ] [ parse-tag ] [ (parse-html) ] tri
    ] [ drop ] if ;

: tag-parse ( quot -- vector )
    V{ } clone tagstack [ state-parse ] with-variable ; inline

: parse-html ( string -- vector )
    [ (parse-html) tagstack get ] tag-parse ;
