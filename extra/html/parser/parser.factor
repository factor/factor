! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays hashtables html.parser.state
html.parser.utils kernel make namespaces sequences
unicode.case unicode.categories combinators.short-circuit
quoting ;
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
    [ [ first ] [ peek ] bi [ CHAR: / = ] bi@ or ] if-empty ;

: <tag> ( name attributes closing? -- tag )
    tag new
        swap >>closing?
        swap >>attributes
        swap >>name ;

: make-tag ( string attribs -- tag )
    [ [ closing-tag? ] keep "/" trim1 ] dip rot <tag> ;

: new-tag ( string type -- tag )
    tag new
        swap >>name
        swap >>text ; inline

: make-text-tag ( string -- tag ) text new-tag ; inline

: make-comment-tag ( string -- tag ) comment new-tag ; inline

: make-dtd-tag ( string -- tag ) dtd new-tag ; inline

: read-single-quote ( state-parser -- string )
    [ [ CHAR: ' = ] take-until ] [ next drop ] bi ;

: read-double-quote ( state-parser -- string )
    [ [ CHAR: " = ] take-until ] [ next drop ] bi ;

: read-quote ( state-parser -- string )
    dup get+increment CHAR: ' =
    [ read-single-quote ] [ read-double-quote ] if ;

: read-key ( state-parser -- string )
    skip-whitespace
    [ { [ CHAR: = = ] [ blank? ] } 1|| ] take-until ;

: read-= ( state-parser -- )
    skip-whitespace
    [ [ CHAR: = = ] take-until drop ] [ next drop ] bi ;

: read-token ( state-parser -- string )
    [ blank? ] take-until ;

: read-value ( state-parser -- string )
    skip-whitespace
    dup get-char quote? [ read-quote ] [ read-token ] if
    [ blank? ] trim ;

: read-comment ( state-parser -- )
    "-->" take-until-string make-comment-tag push-tag ;

: read-dtd ( state-parser -- )
    ">" take-until-string make-dtd-tag push-tag ;

: read-bang ( state-parser -- )
    next dup { [ get-char CHAR: - = ] [ get-next CHAR: - = ] } 1&& [
        next next
        read-comment
    ] [
        read-dtd
    ] if ;

: read-tag ( state-parser -- string )
    [ [ "><" member? ] take-until ]
    [ dup get-char CHAR: < = [ next ] unless drop ] bi ;

: read-until-< ( state-parser -- string )
    [ CHAR: < = ] take-until ;

: parse-text ( state-parser -- )
    read-until-< [ make-text-tag push-tag ] unless-empty ;

: (parse-attributes) ( state-parser -- )
    skip-whitespace
    dup string-parse-end? [
        drop
    ] [
        [
            [ read-key >lower ] [ read-= ] [ read-value ] tri
            2array ,
        ] keep (parse-attributes)
    ] if ;

: parse-attributes ( state-parser -- hashtable )
    [ (parse-attributes) ] { } make >hashtable ;

: (parse-tag) ( string -- string' hashtable )
    [
        [ read-token >lower ] [ parse-attributes ] bi
    ] string-parse ;

: read-< ( state-parser -- string/f )
    next dup get-char [
        CHAR: ! = [ read-bang f ] [ read-tag ] if
    ] [
        drop f
    ] if* ;

: parse-tag ( state-parser -- )
    read-< [ (parse-tag) make-tag push-tag ] unless-empty ;

: (parse-html) ( state-parser -- )
    dup get-next [
        [ parse-text ] [ parse-tag ] [ (parse-html) ] tri
    ] [ drop ] if ;

: tag-parse ( quot -- vector )
    V{ } clone tagstack [ string-parse ] with-variable ; inline

: parse-html ( string -- vector )
    [ (parse-html) tagstack get ] tag-parse ;
