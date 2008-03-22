USING: alien alien.c-types kernel windows.ole32
combinators.lib parser splitting sequences.lib
sequences namespaces combinators.cleave
assocs quotations shuffle accessors words macros
alien.syntax fry ;
IN: windows.com.syntax

<PRIVATE

C-STRUCT: com-interface
    { "void*" "vtbl" } ;

MACRO: com-invoke ( n return parameters -- )
    dup length -roll
    '[
        , npick com-interface-vtbl , swap void*-nth , ,
        "stdcall" alien-indirect
    ] ;

TUPLE: com-interface-definition name parent iid functions ;
C: <com-interface-definition> com-interface-definition

TUPLE: com-function-definition name return parameters ;
C: <com-function-definition> com-function-definition

SYMBOL: +com-interface-definitions+
+com-interface-definitions+ get-global
[ H{ } +com-interface-definitions+ set-global ]
unless

: find-com-interface-definition ( name -- definition )
    dup "f" = [ drop f ] [
        dup +com-interface-definitions+ get-global at*
        [ nip ]
        [ swap " COM interface hasn't been defined" append throw ]
        if
    ] if ;

: save-com-interface-definition ( definition -- )
    dup name>> +com-interface-definitions+ get-global set-at ;

: (parse-com-function) ( tokens -- definition )
    [ second ]
    [ first ]
    [ 3 tail 2 group [ first ] map "void*" add* ]
    tri
    <com-function-definition> ;

: parse-com-functions ( -- functions )
    ";" parse-tokens { ")" } split
    [ empty? not ] subset
    [ (parse-com-function) ] map ;

: (iid-word) ( definition -- word )
    name>> "-iid" append create-in ;

: (function-word) ( function interface -- word )
    name>> "::" rot name>> 3append create-in ;

: all-functions ( definition -- functions )
    dup parent>> [ all-functions ] [ { } ] if*
    swap functions>> append ;

: (define-word-for-function) ( function interface n -- )
    -rot [ (function-word) swap ] 2keep drop
    { return>> parameters>> } get-slots
    [ com-invoke ] 3curry
    define ;

: define-words-for-com-interface ( definition -- )
    [ [ (iid-word) ] [ iid>> 1quotation ] bi define ]
    [ name>> "com-interface" swap typedef ]
    [
        dup all-functions
        [ (define-word-for-function) ] with each-index
    ]
    tri ;

PRIVATE>

: COM-INTERFACE:
    scan
    scan find-com-interface-definition
    scan string>guid
    parse-com-functions
    <com-interface-definition>
    dup save-com-interface-definition
    define-words-for-com-interface
    ; parsing

