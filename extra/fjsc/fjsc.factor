! Copyright (C) 2006 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel peg strings sequences math math.parser
make words quotations arrays hashtables io
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

: identifier-ends-parser ( -- parser )
    [
        {
            [ blank? not ]
            [ CHAR: \" = not ]
            [ CHAR: ; = not ]
            [ LETTER? not ]
            [ letter? not ]
            [ identifier-middle? not ]
        } 1&&
    ] satisfy repeat0 ;

: identifier-middle-parser ( -- parser )
    [ identifier-middle? ] satisfy repeat1 ;

: identifier-parser ( -- parser )
    [
        identifier-ends-parser ,
        identifier-middle-parser ,
        identifier-ends-parser ,
    ] seq* [
        "" concat-as f ast-identifier boa
    ] action ;


DEFER: expression-parser

: effect-name-parser ( -- parser )
    [
        {
            [ blank? not ]
            [ CHAR: ) = not ]
            [ CHAR: - = not ]
        } 1&&
    ] satisfy repeat1 [ >string ] action ;

: stack-effect-parser ( -- parser )
    [
        "(" token hide ,
        effect-name-parser sp repeat0 ,
        "--" token sp hide ,
        effect-name-parser sp repeat0 ,
        ")" token sp hide ,
    ] seq* [
        first2 ast-stack-effect boa
    ] action ;

: define-parser ( -- parser )
    [
        ":" token sp hide ,
        identifier-parser sp [ value>> ] action ,
        stack-effect-parser sp optional ,
        expression-parser ,
        ";" token sp hide ,
    ] seq* [ first3 ast-define boa ] action ;

: quotation-parser ( -- parser )
    [
        "[" token sp hide ,
        expression-parser [ values>> ] action ,
        "]" token sp hide ,
    ] seq* [ first ast-quotation boa ] action ;

: array-parser ( -- parser )
    [
        "{" token sp hide ,
        expression-parser [ values>> ] action ,
        "}" token sp hide ,
    ] seq* [ first ast-array boa ] action ;

: word-parser ( -- parser )
    [
        "\\" token sp hide ,
        identifier-parser sp ,
    ] seq* [ first value>> f ast-word boa ] action ;

: atom-parser ( -- parser )
    [
        identifier-parser ,
        integer-parser [ ast-number boa ] action ,
        string-parser [ ast-string boa ] action ,
    ] choice* ;

: comment-parser ( -- parser )
    [
        "!" token hide ,
        [
            dup CHAR: \n = swap CHAR: \r = or not
        ] satisfy repeat0 ,
    ] seq* [ drop ast-comment boa ] action ;

: USE-parser ( -- parser )
    [
        "USE:" token sp hide ,
        identifier-parser sp ,
    ] seq* [ first value>> ast-use boa ] action ;

: IN-parser ( -- parser )
    [
        "IN:" token sp hide ,
        identifier-parser sp ,
    ] seq* [ first value>> ast-in boa ] action ;

: USING-parser ( -- parser )
    [
        "USING:" token sp hide ,
        identifier-parser sp [ value>> ] action repeat1 ,
        ";" token sp hide ,
    ] seq* [ first ast-using boa ] action ;

: hashtable-parser ( -- parser )
    [
        "H{" token sp hide ,
        expression-parser [ values>> ] action ,
        "}" token sp hide ,
    ] seq* [ first ast-hashtable boa ] action ;

: parsing-word-parser ( -- parser )
    [
        USE-parser ,
        USING-parser ,
        IN-parser ,
    ] choice* ;

: expression-parser ( -- parser )
    [
        [
            comment-parser ,
            parsing-word-parser sp ,
            quotation-parser sp ,
            define-parser sp ,
            array-parser sp ,
            hashtable-parser sp ,
            word-parser sp ,
            atom-parser sp ,
        ] choice* repeat0 [ ast-expression boa ] action
    ] delay ;

: statement-parser ( -- parser )
    expression-parser ;

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

M: number (parse-factor-quotation)
    ast-number boa ;

M: symbol (parse-factor-quotation)
    [ >string ] [ vocabulary>> ] bi ast-identifier boa ;

M: word (parse-factor-quotation)
    [ name>> ] [ vocabulary>> ] bi ast-identifier boa ;

M: string (parse-factor-quotation)
    ast-string boa ;

M: quotation (parse-factor-quotation)
    [ (parse-factor-quotation) ] { } map-as ast-quotation boa ;

M: array (parse-factor-quotation)
    [ (parse-factor-quotation) ] { } map-as ast-array boa ;

M: hashtable (parse-factor-quotation)
    >alist [ (parse-factor-quotation) ] { } map-as ast-hashtable boa ;

M: wrapper (parse-factor-quotation)
    wrapped>> [ name>> ] [ vocabulary>> ] bi ast-word boa ;

GENERIC: fjsc-parse ( object -- ast )

M: string fjsc-parse
    expression-parser parse ;

M: quotation fjsc-parse
    [ (parse-factor-quotation) ] { } map-as ast-expression boa ;

: fjsc-compile ( ast -- string )
    [
        [
            "(" ,
            (compile)
            ")" ,
        ] { } make [ write ] each
    ] with-string-writer ;

: fjsc-compile* ( string -- string )
    statement-parser parse fjsc-compile ;

: fc* ( string -- )
    [
        statement-parser parse values>> do-expressions
    ] { } make [ write ] each ;

: fjsc-literal ( ast -- string )
    [
        [ (literal) ] { } make [ write ] each
    ] with-string-writer ;
