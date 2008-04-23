! Copyright (C) 2005, 2008 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.structs alien.arrays
alien.strings kernel math namespaces parser sequences words
quotations math.parser splitting effects prettyprint
prettyprint.sections prettyprint.backend assocs combinators ;
IN: alien.syntax

<PRIVATE

: parse-arglist ( return seq -- types effect )
    2 group dup keys swap values [ "," ?tail drop ] map
    rot dup "void" = [ drop { } ] [ 1array ] if <effect> ;

: function-quot ( type lib func types -- quot )
    [ alien-invoke ] 2curry 2curry ;

: define-function ( return library function parameters -- )
    >r pick r> parse-arglist
    pick create-in dup reset-generic
    >r >r function-quot r> r> 
    -rot define-declared ;

PRIVATE>

: indirect-quot ( function-ptr-quot return types abi -- quot )
    [ alien-indirect ] 3curry compose ;

: define-indirect ( abi return function-ptr-quot function-name parameters -- )
    >r pick r> parse-arglist
    rot create-in dup reset-generic
    >r >r swapd roll indirect-quot r> r>
    -rot define-declared ;

: DLL" lexer get skip-blank parse-string dlopen parsed ; parsing

: ALIEN: scan string>number <alien> parsed ; parsing

: LIBRARY: scan "c-library" set ; parsing

: FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] subset
    define-function ; parsing

: TYPEDEF:
    scan scan typedef ; parsing

: TYPEDEF-IF:
    scan-word execute scan scan rot [ typedef ] [ 2drop ] if ; parsing

: C-STRUCT:
    scan in get
    parse-definition
    >r 2dup r> define-struct-early
    define-struct ; parsing

: C-UNION:
    scan in get parse-definition define-union ; parsing

: C-ENUM:
    ";" parse-tokens
    dup length
    [ >r create-in r> 1quotation define ] 2each ;
    parsing

M: alien pprint*
    {
        { [ dup expired? ] [ drop "( alien expired )" text ] }
        { [ dup pinned-c-ptr? not ] [ drop "( displaced alien )" text ] }
        [ \ ALIEN: [ alien-address pprint* ] pprint-prefix ]
    } cond ;

M: dll pprint* dll-path dup "DLL\" " "\"" pprint-string ;
