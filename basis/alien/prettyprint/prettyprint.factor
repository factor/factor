! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel combinators alien alien.strings alien.c-types
alien.syntax arrays math.parser prettyprint.backend
prettyprint.custom prettyprint.sections definitions see see.private
strings words ;
IN: alien.prettyprint

M: alien pprint*
    {
        { [ dup expired? ] [ drop \ BAD-ALIEN pprint-word ] }
        { [ dup pinned-c-ptr? not ] [ drop "( displaced alien )" text ] }
        [ \ ALIEN: [ alien-address >hex text ] pprint-prefix ]
    } cond ;

M: dll pprint* dll-path dup "DLL\" " "\"" pprint-string ;

M: c-type-word definer drop \ C-TYPE: f ;
M: c-type-word definition drop f ;

GENERIC: pprint-c-type ( c-type -- )
M: word pprint-c-type pprint-word ;
M: string pprint-c-type text ;
M: array pprint-c-type pprint* ;

M: typedef-word see-class*
    <colon
    \ TYPEDEF: pprint-word
    dup "c-type" word-prop pprint-c-type
    pprint-word
    block> ;
