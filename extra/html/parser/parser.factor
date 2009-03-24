! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays html.parser.utils hashtables io kernel
namespaces make prettyprint quotations sequences splitting
html.parser.state strings unicode.categories unicode.case ;
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

: make-text-tag ( string -- tag )
    tag new
        text >>name
        swap >>text ;

: make-comment-tag ( string -- tag )
    tag new
        comment >>name
        swap >>text ;

: make-dtd-tag ( string -- tag )
    tag new
        dtd >>name
        swap >>text ;

: read-whitespace ( -- string )
    [ get-char blank? not ] take-until ;

: read-whitespace* ( -- ) read-whitespace drop ;

: read-token ( -- string )
    read-whitespace*
    [ get-char blank? ] take-until ;

: read-single-quote ( -- string )
    [ get-char CHAR: ' = ] take-until ;

: read-double-quote ( -- string )
    [ get-char CHAR: " = ] take-until ;

: read-quote ( -- string )
    get-char next CHAR: ' =
    [ read-single-quote ] [ read-double-quote ] if next ;

: read-key ( -- string )
    read-whitespace*
    [ get-char [ CHAR: = = ] [ blank? ] bi or ] take-until ;

: read-= ( -- )
    read-whitespace*
    [ get-char CHAR: = = ] take-until drop next ;

: read-value ( -- string )
    read-whitespace*
    get-char quote? [ read-quote ] [ read-token ] if
    [ blank? ] trim ;

: read-comment ( -- )
    "-->" take-string make-comment-tag push-tag ;

: read-dtd ( -- )
    ">" take-string make-dtd-tag push-tag ;

: read-bang ( -- )
    next get-char CHAR: - = get-next CHAR: - = and [
        next next
        read-comment
    ] [
        read-dtd
    ] if ;

: read-tag ( -- string )
    [ get-char CHAR: > = get-char CHAR: < = or ] take-until
    get-char CHAR: < = [ next ] unless ;

: read-< ( -- string )
    next get-char CHAR: ! = [
        read-bang f
    ] [
        read-tag
    ] if ;

: read-until-< ( -- string )
    [ get-char CHAR: < = ] take-until ;

: parse-text ( -- )
    read-until-< [
        make-text-tag push-tag
    ] unless-empty ;

: (parse-attributes) ( -- )
    read-whitespace*
    string-parse-end? [
        read-key >lower read-= read-value
        2array , (parse-attributes)
    ] unless ;

: parse-attributes ( -- hashtable )
    [ (parse-attributes) ] { } make >hashtable ;

: (parse-tag) ( string -- string' hashtable )
    [
        read-token >lower
        parse-attributes
    ] string-parse ;

: parse-tag ( -- )
    read-< [
        (parse-tag) make-tag push-tag
    ] unless-empty ;

: (parse-html) ( -- )
    get-next [
        parse-text
        parse-tag
        (parse-html)
    ] when ;

: tag-parse ( quot -- vector )
    V{ } clone tagstack [ string-parse ] with-variable ; inline

: parse-html ( string -- vector )
    [ (parse-html) tagstack get ] tag-parse ;
