! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel peg strings sequences math math.parser
namespaces make words quotations arrays hashtables io
io.streams.string assocs ascii peg.parsers words.symbol
combinators.short-circuit ;
IN: fjsc

TUPLE: ast-number value ;
TUPLE: ast-identifier value vocab ;
TUPLE: ast-string value ;
TUPLE: ast-quotation values ;
TUPLE: ast-array elements ;
TUPLE: ast-define name stack-effect expression ;
TUPLE: ast-expression values ;
TUPLE: ast-word value vocab ;
TUPLE: ast-comment ;
TUPLE: ast-stack-effect in out ;
TUPLE: ast-use name ;
TUPLE: ast-using names ;
TUPLE: ast-in name ;
TUPLE: ast-hashtable elements ;

: identifier-middle? ( ch -- bool )
    {
        [ blank? not ]
        [ "}];\"" member? not ]
        [ digit? not ]
    } 1&& ;

: 'identifier-ends' ( -- parser )
    [
        {
            [ blank? not ]
            [ CHAR: " = not ]
            [ CHAR: ; = not ]
            [ LETTER? not ]
            [ letter? not ]
            [ identifier-middle? not ]
        } 1&&
    ] satisfy repeat0 ;

: 'identifier-middle' ( -- parser )
    [ identifier-middle? ] satisfy repeat1 ;

: 'identifier' ( -- parser )
    [
        'identifier-ends' ,
        'identifier-middle' ,
        'identifier-ends' ,
    ] seq* [
        "" concat-as f ast-identifier boa
    ] action ;


DEFER: 'expression'

: 'effect-name' ( -- parser )
    [
        {
            [ blank? not ]
            [ CHAR: ) = not ]
            [ CHAR: - = not ]
        } 1&&
    ] satisfy repeat1 [ >string ] action ;

: 'stack-effect' ( -- parser )
    [
        "(" token hide ,
        'effect-name' sp repeat0 ,
        "--" token sp hide ,
        'effect-name' sp repeat0 ,
        ")" token sp hide ,
    ] seq* [
        first2 ast-stack-effect boa
    ] action ;

: 'define' ( -- parser )
    [
        ":" token sp hide ,
        'identifier' sp [ value>> ] action ,
        'stack-effect' sp optional ,
        'expression' ,
        ";" token sp hide ,
    ] seq* [ first3 ast-define boa ] action ;

: 'quotation' ( -- parser )
    [
        "[" token sp hide ,
        'expression' [ values>> ] action ,
        "]" token sp hide ,
    ] seq* [ first ast-quotation boa ] action ;

: 'array' ( -- parser )
    [
        "{" token sp hide ,
        'expression' [ values>> ] action ,
        "}" token sp hide ,
    ] seq* [ first ast-array boa ] action ;

: 'word' ( -- parser )
    [
        "\\" token sp hide ,
        'identifier' sp ,
    ] seq* [ first value>> f ast-word boa ] action ;

: 'atom' ( -- parser )
    [
        'identifier' ,
        'integer' [ ast-number boa ] action ,
        'string' [ ast-string boa ] action ,
    ] choice* ;

: 'comment' ( -- parser )
    [
        [
            "#!" token sp ,
            "!" token sp ,
        ] choice* hide ,
        [
            dup CHAR: \n = swap CHAR: \r = or not
        ] satisfy repeat0 ,
    ] seq* [ drop ast-comment boa ] action ;

: 'USE:' ( -- parser )
    [
        "USE:" token sp hide ,
        'identifier' sp ,
    ] seq* [ first value>> ast-use boa ] action ;

: 'IN:' ( -- parser )
    [
        "IN:" token sp hide ,
        'identifier' sp ,
    ] seq* [ first value>> ast-in boa ] action ;

: 'USING:' ( -- parser )
    [
        "USING:" token sp hide ,
        'identifier' sp [ value>> ] action repeat1 ,
        ";" token sp hide ,
    ] seq* [ first ast-using boa ] action ;

: 'hashtable' ( -- parser )
    [
        "H{" token sp hide ,
        'expression' [ values>> ] action ,
        "}" token sp hide ,
    ] seq* [ first ast-hashtable boa ] action ;

: 'parsing-word' ( -- parser )
    [
        'USE:' ,
        'USING:' ,
        'IN:' ,
    ] choice* ;

: 'expression' ( -- parser )
    [
        [
            'comment' ,
            'parsing-word' sp ,
            'quotation' sp ,
            'define' sp ,
            'array' sp ,
            'hashtable' sp ,
            'word' sp ,
            'atom' sp ,
        ] choice* repeat0 [ ast-expression boa ] action
    ] delay ;

: 'statement' ( -- parser )
    'expression' ;

GENERIC: (compile) ( ast -- )
GENERIC: (literal) ( ast -- )

M: ast-number (literal)
    value>> number>string , ;

M: ast-number (compile)
    "factor.push_data(" ,
    (literal)
    "," , ;

M: ast-string (literal)
    "\"" ,
    value>> ,
    "\"" , ;

M: ast-string (compile)
    "factor.push_data(" ,
    (literal)
    "," , ;

M: ast-identifier (literal)
    dup vocab>> [
        "factor.get_word(\"" ,
        dup vocab>> ,
        "\",\"" ,
        value>> ,
        "\")" ,
    ] [
        "factor.find_word(\"" , value>> , "\")" ,
    ] if ;

M: ast-identifier (compile)
    (literal) ".execute(" ,  ;

M: ast-define (compile)
    "factor.define_word(\"" ,
    dup name>> ,
    "\",\"source\"," ,
    expression>> (compile)
    "," , ;

: do-expressions ( seq -- )
    dup empty? not [
        unclip
        dup ast-comment? not [
            "function() {" ,
            (compile)
            do-expressions
            ")}" ,
        ] [
            drop do-expressions
        ] if
    ] [
        drop "factor.cont.next" ,
    ] if  ;

M: ast-quotation (literal)
    "factor.make_quotation(\"source\"," ,
    values>> do-expressions
    ")" , ;

M: ast-quotation (compile)
    "factor.push_data(factor.make_quotation(\"source\"," ,
    values>> do-expressions
    ")," , ;

M: ast-array (literal)
    "[" ,
    elements>> [ "," , ] [ (literal) ] interleave
    "]" , ;

M: ast-array (compile)
    "factor.push_data(" , (literal) "," , ;

M: ast-hashtable (literal)
    "new Hashtable().fromAlist([" ,
    elements>> [ "," , ] [ (literal) ] interleave
    "])" , ;

M: ast-hashtable (compile)
    "factor.push_data(" , (literal) "," , ;


M: ast-expression (literal)
    values>> [
        (literal)
    ] each ;

M: ast-expression (compile)
    values>> do-expressions ;

M: ast-word (literal)
    dup vocab>> [
        "factor.get_word(\"" ,
        dup vocab>> ,
        "\",\"" ,
        value>> ,
        "\")" ,
    ] [
        "factor.find_word(\"" , value>> , "\")" ,
    ] if ;

M: ast-word (compile)
    "factor.push_data(" ,
    (literal)
    "," , ;

M: ast-comment (compile)
    drop ;

M: ast-stack-effect (compile)
    drop ;

M: ast-use (compile)
    "factor.use(\"" ,
    name>> ,
    "\"," , ;

M: ast-in (compile)
    "factor.set_in(\"" ,
    name>> ,
    "\"," , ;

M: ast-using (compile)
    "factor.using([" ,
        names>> [
        "," ,
    ] [
        "\"" , , "\"" ,
    ] interleave
    "]," , ;

GENERIC: (parse-factor-quotation) ( object -- ast )

M: number (parse-factor-quotation) ( object -- ast )
    ast-number boa ;

M: symbol (parse-factor-quotation) ( object -- ast )
    dup >string swap vocabulary>> ast-identifier boa ;

M: word (parse-factor-quotation) ( object -- ast )
    dup name>> swap vocabulary>> ast-identifier boa ;

M: string (parse-factor-quotation) ( object -- ast )
    ast-string boa ;

M: quotation (parse-factor-quotation) ( object -- ast )
    [
        [ (parse-factor-quotation) , ] each
    ] { } make ast-quotation boa ;

M: array (parse-factor-quotation) ( object -- ast )
    [
        [ (parse-factor-quotation) , ] each
    ] { } make ast-array boa ;

M: hashtable (parse-factor-quotation) ( object -- ast )
    >alist [
        [ (parse-factor-quotation) , ] each
    ] { } make ast-hashtable boa ;

M: wrapper (parse-factor-quotation) ( object -- ast )
    wrapped>> dup name>> swap vocabulary>> ast-word boa ;

GENERIC: fjsc-parse ( object -- ast )

M: string fjsc-parse ( object -- ast )
    'expression' parse ;

M: quotation fjsc-parse ( object -- ast )
    [
        [ (parse-factor-quotation) , ] each
    ] { } make ast-expression boa ;

: fjsc-compile ( ast -- string )
    [
        [
            "(" ,
            (compile)
            ")" ,
        ] { } make [ write ] each
    ] with-string-writer ;

: fjsc-compile* ( string -- string )
    'statement' parse fjsc-compile ;

: fc* ( string -- )
    [
        'statement' parse values>> do-expressions
    ] { } make [ write ] each ;


: fjsc-literal ( ast -- string )
    [
        [ (literal) ] { } make [ write ] each
    ] with-string-writer ;

