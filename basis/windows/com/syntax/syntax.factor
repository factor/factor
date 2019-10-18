USING: alien alien.c-types alien.data alien.accessors
alien.parser effects kernel windows.ole32 parser lexer splitting
grouping sequences namespaces assocs quotations generalizations
accessors words macros alien.syntax fry arrays layouts math
classes.struct windows.kernel32 locals ;
FROM: alien.parser.private => parse-pointers ;
IN: windows.com.syntax

<PRIVATE

MACRO: com-invoke ( n return parameters -- quot )
    [ 2nip length ] 3keep
    '[
        _ npick void* deref _ cell * alien-cell _ _
        stdcall alien-indirect
    ] ;

TUPLE: com-interface-definition word parent iid functions ;
C: <com-interface-definition> com-interface-definition

TUPLE: com-function-definition return name parameter-types parameter-names ;
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

: (parse-com-function) ( return name -- definition )
    scan-c-args
    [ pointer: void prefix ] [ "this" prefix ] bi*
    <com-function-definition> ;

:: (parse-com-functions) ( functions -- )
    scan-token dup ";" = [ drop ] [
        parse-c-type scan-token parse-pointers
        (parse-com-function) functions push
        functions (parse-com-functions)
    ] if ;

: parse-com-functions ( -- functions )
    V{ } clone [ (parse-com-functions) ] keep >array ;

: (iid-word) ( definition -- word )
    word>> name>> "-iid" append create-word-in ;

: (function-word) ( function interface -- word )
    swap [ word>> name>> "::" ] [ name>> ] bi*
    3append create-word-in ;

: family-tree ( definition -- definitions )
    dup parent>> [ family-tree ] [ { } ] if*
    swap suffix ;

: family-tree-functions ( definition -- functions )
    dup parent>> [ family-tree-functions ] [ { } ] if*
    swap functions>> append ;

:: (define-word-for-function) ( function interface n -- )
    function interface (function-word)
    n function [ return>> ] [ parameter-types>> ] bi '[ _ _ _ com-invoke ]
    function [ parameter-names>> ] [ return>> ] bi function-effect
    define-declared ;

: define-words-for-com-interface ( definition -- )
    [ [ (iid-word) ] [ iid>> 1quotation ] bi ( -- iid ) define-declared ]
    [
        dup family-tree-functions
        [ (define-word-for-function) ] with each-index
    ] bi ;

PRIVATE>

SYNTAX: COM-INTERFACE:
    CREATE-C-TYPE
    void* over typedef
    scan-object find-com-interface-definition
    scan-token string>guid
    parse-com-functions
    <com-interface-definition>
    dup save-com-interface-definition
    define-words-for-com-interface ;

SYNTAX: GUID: scan-token string>guid suffix! ;

USE: vocabs.loader

{ "windows.com" "prettyprint" } "windows.com.prettyprint" require-when
