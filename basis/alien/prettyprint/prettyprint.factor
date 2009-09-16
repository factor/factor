! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators alien alien.strings alien.c-types
alien.parser alien.syntax arrays assocs effects math.parser
prettyprint.backend prettyprint.custom prettyprint.sections
definitions see see.private sequences strings words ;
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
M: typedef-word declarations. drop ;

GENERIC: pprint-c-type ( c-type -- )
M: word pprint-c-type pprint-word ;
M: wrapper pprint-c-type wrapped>> pprint-word ;
M: string pprint-c-type text ;
M: array pprint-c-type pprint* ;

M: typedef-word definer drop \ TYPEDEF: f ;

M: typedef-word synopsis*
    \ TYPEDEF: pprint-word
    dup "c-type" word-prop pprint-c-type
    pprint-word ;

: pprint-function-arg ( type name -- )
    [ pprint-c-type ] [ text ] bi* ;

: pprint-function-args ( word -- )
    [ def>> fourth ] [ stack-effect in>> ] bi zip [ ] [
        unclip-last
        [ [ first2 "," append pprint-function-arg ] each ] dip
        first2 pprint-function-arg
    ] if-empty ;

M: alien-function-word definer
    drop \ FUNCTION: \ ; ;
M: alien-function-word definition drop f ;
M: alien-function-word synopsis*
    \ FUNCTION: pprint-word
    [ def>> first pprint-c-type ]
    [ pprint-word ]
    [ <block "(" text pprint-function-args ")" text block> ] tri ;
