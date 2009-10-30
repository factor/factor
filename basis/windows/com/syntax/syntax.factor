USING: alien alien.c-types alien.accessors alien.parser
effects kernel windows.ole32 parser lexer splitting grouping
sequences namespaces assocs quotations generalizations
accessors words macros alien.syntax fry arrays layouts math
classes.struct windows.kernel32 ;
IN: windows.com.syntax

<PRIVATE

MACRO: com-invoke ( n return parameters -- )
    [ 2nip length ] 3keep
    '[
        _ npick *void* _ cell * alien-cell _ _
        "stdcall" alien-indirect
    ] ;

TUPLE: com-interface-definition word parent iid functions ;
C: <com-interface-definition> com-interface-definition

TUPLE: com-function-definition name return parameters ;
C: <com-function-definition> com-function-definition

SYMBOL: +com-interface-definitions+
+com-interface-definitions+ get-global
[ H{ } +com-interface-definitions+ set-global ]
unless

ERROR: no-com-interface interface ;

: find-com-interface-definition ( name -- definition )
    [
        dup +com-interface-definitions+ get-global at*
        [ nip ] [ drop no-com-interface ] if
    ] [ f ] if* ;

: save-com-interface-definition ( definition -- )
    dup word>> +com-interface-definitions+ get-global set-at ;

: (parse-com-function) ( tokens -- definition )
    [ second ]
    [ first ]
    [
        3 tail [ CHAR: , swap remove ] map
        2 group [ first2 normalize-c-arg 2array ] map
        { void* "this" } prefix
    ] tri
    <com-function-definition> ;

: parse-com-functions ( -- functions )
    ";" parse-tokens { ")" } split harvest
    [ (parse-com-function) ] map ;

: (iid-word) ( definition -- word )
    word>> name>> "-iid" append create-in ;

: (function-word) ( function interface -- word )
    swap [ word>> name>> "::" ] [ name>> ] bi*
    3append create-in ;

: family-tree ( definition -- definitions )
    dup parent>> [ family-tree ] [ { } ] if*
    swap suffix ;

: family-tree-functions ( definition -- functions )
    dup parent>> [ family-tree-functions ] [ { } ] if*
    swap functions>> append ;

: (invocation-quot) ( function return parameters -- quot )
    [ first ] map [ com-invoke ] 3curry ;

: (stack-effect-from-return-and-parameters) ( return parameters -- stack-effect )
    swap
    [ [ second ] map ]
    [ dup void? [ drop { } ] [ 1array ] if ] bi*
    <effect> ;

: (define-word-for-function) ( function interface n -- )
    -rot [ (function-word) swap ] 2keep drop
    [ return>> ] [ parameters>> ] bi
    [ (invocation-quot) ] 2keep
    (stack-effect-from-return-and-parameters)
    define-declared ;

: define-words-for-com-interface ( definition -- )
    [ [ (iid-word) ] [ iid>> 1quotation ] bi (( -- iid )) define-declared ]
    [ word>> void* swap typedef ]
    [
        dup family-tree-functions
        [ (define-word-for-function) ] with each-index
    ]
    tri ;

PRIVATE>

SYNTAX: COM-INTERFACE:
    CREATE-C-TYPE
    scan-object find-com-interface-definition
    scan string>guid
    parse-com-functions
    <com-interface-definition>
    dup save-com-interface-definition
    define-words-for-com-interface ;

SYNTAX: GUID: scan string>guid suffix! ;

USING: vocabs vocabs.loader ;

"prettyprint" vocab [
    "windows.com.prettyprint" require
] when
