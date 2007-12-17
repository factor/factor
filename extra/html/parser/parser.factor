USING: arrays html.parser.utils hashtables io kernel
namespaces prettyprint quotations
sequences splitting state-parser strings ;
IN: html.parser

TUPLE: tag name attributes text matched? closing? ;

SYMBOL: text
SYMBOL: dtd
SYMBOL: comment
SYMBOL: javascript
SYMBOL: tagstack

: push-tag ( tag -- )
    tagstack get push ;

: closing-tag? ( string -- ? )
    dup empty? [
        drop f
    ] [
        dup first CHAR: / =
        swap peek CHAR: / = or
    ] if ;

: <tag> ( name attributes closing? -- tag )
    { set-tag-name set-tag-attributes set-tag-closing? }
    tag construct ;

: make-tag ( str attribs -- tag )
    >r [ closing-tag? ] keep "/" trim1 r> rot <tag> ;

: make-text-tag ( str -- tag )
    T{ tag f text } clone [ set-tag-text ] keep ;

: make-comment-tag ( str -- tag )
    T{ tag f comment } clone [ set-tag-text ] keep ;

: make-dtd-tag ( str -- tag )
    T{ tag f dtd } clone [ set-tag-text ] keep ;

: read-whitespace ( -- str )
    [ get-char blank? not ] take-until ;

: read-whitespace* ( -- )
    read-whitespace drop ;

: read-token ( -- str )
    read-whitespace*
    [ get-char blank? ] take-until ;

: read-single-quote ( -- str )
    [ get-char CHAR: ' = ] take-until ;

: read-double-quote ( -- str )
    [ get-char CHAR: " = ] take-until ;

: read-quote ( -- str )
    get-char next* CHAR: ' = [
        read-single-quote
    ] [
        read-double-quote
    ] if next* ;

: read-key ( -- str )
    read-whitespace*
    [ get-char CHAR: = = get-char blank? or ] take-until ;

: read-= ( -- )
    read-whitespace*
    [ get-char CHAR: = = ] take-until drop next* ;

: read-value ( -- str )
    read-whitespace*
    get-char quote? [
        read-quote
    ] [
        read-token
    ] if ;

: read-comment ( -- )
    "-->" take-string* make-comment-tag push-tag ;

: read-dtd ( -- )
    ">" take-string* make-dtd-tag push-tag ;

: read-bang ( -- )
    next* get-char CHAR: - = get-next CHAR: - = and [
        next* next*
        read-comment
    ] [
        read-dtd
    ] if ;

: read-tag ( -- )
    [ get-char CHAR: > = get-char CHAR: < = or ] take-until
    get-char CHAR: < = [ next* ] unless ;

: read-< ( -- str )
    next* get-char CHAR: ! = [
        read-bang f
    ] [
        read-tag
    ] if ;

: read-until-< ( -- str )
    [ get-char CHAR: < = ] take-until ;

: parse-text ( -- )
    read-until-< dup empty? [
        drop
    ] [
        make-text-tag push-tag
    ] if ;

: (parse-attributes) ( -- )
    read-whitespace*
    string-parse-end? [
        read-key >lower read-= read-value
        2array , (parse-attributes)
    ] unless ;

: parse-attributes ( -- hashtable )
    [ (parse-attributes) ] { } make >hashtable ;

: (parse-tag)
    [
        read-token >lower
        parse-attributes
    ] string-parse ;

: parse-tag ( -- )
    read-< dup empty? [
        drop
    ] [
        (parse-tag) make-tag push-tag
    ] if ;

: (parse-html) ( tag -- )
    get-next [
        parse-text
        parse-tag
        (parse-html)
    ] when ;

: tag-parse ( quot -- vector )
    [
        V{ } clone tagstack set
        string-parse
    ] with-scope ;

: parse-html ( string -- vector )
    [
        (parse-html)
        tagstack get
    ] tag-parse ;
