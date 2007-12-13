! Copyright (C) 2005, 2007 Slava Pestov, Alex Chapman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays alien alien.c-types alien.structs kernel math
namespaces parser sequences words quotations math.parser
splitting effects prettyprint prettyprint.sections
prettyprint.backend assocs combinators ;
IN: alien.syntax

<PRIVATE

: parse-arglist ( return seq -- types effect )
    2 group dup keys swap values
    rot dup "void" = [ drop { } ] [ 1array ] if <effect> ;

: function-quot ( type lib func types -- quot )
    [ alien-invoke ] 2curry 2curry ;

: define-function ( return library function parameters -- )
    >r pick r> parse-arglist
    pick create-in dup reset-generic
    >r >r function-quot r> r> 
    -rot define-declared ;

PRIVATE>

: DLL" skip-blank parse-string dlopen parsed ; parsing

: ALIEN: scan string>number <alien> parsed ; parsing

: LIBRARY: scan "c-library" set ; parsing

: FUNCTION:
    scan "c-library" get scan ";" parse-tokens
    [ "()" subseq? not ] subset
    define-function ; parsing

: TYPEDEF:
    scan scan typedef ; parsing

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
    [ >r create-in r> 1quotation define-compound ] 2each ;
    parsing

M: alien pprint*
    {
        { [ dup expired? ] [ drop "( alien expired )" text ] }
        { [ dup pinned-c-ptr? not ] [ drop "( displaced alien )" text ] }
        { [ t ] [ \ ALIEN: [ alien-address pprint* ] pprint-prefix ] }
    } cond ;

M: dll pprint* dll-path dup "DLL\" " "\"" pprint-string ;
