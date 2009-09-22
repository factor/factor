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
M: c-type-word declarations. drop ;

GENERIC: pprint-c-type ( c-type -- )
M: word pprint-c-type pprint-word ;
M: wrapper pprint-c-type wrapped>> pprint-word ;
M: string pprint-c-type text ;
M: array pprint-c-type pprint* ;

M: typedef-word definer drop \ TYPEDEF: f ;

M: typedef-word synopsis*
    {
        [ seeing-word ]
        [ definer. ]
        [ "c-type" word-prop pprint-c-type ]
        [ pprint-word ]
    } cleave ;

: pprint-function-arg ( type name -- )
    [ pprint-c-type ] [ text ] bi* ;

: pprint-function-args ( types names -- )
    zip [ ] [
        unclip-last
        [ [ first2 "," append pprint-function-arg ] each ] dip
        first2 pprint-function-arg
    ] if-empty ;

M: alien-function-word definer
    drop \ FUNCTION: \ ; ;
M: alien-function-word definition drop f ;
M: alien-function-word synopsis*
    {
        [ seeing-word ]
        [ def>> second [ \ LIBRARY: [ text ] pprint-prefix ] when* ]
        [ definer. ]
        [ def>> first pprint-c-type ]
        [ pprint-word ]
        [
            <block "(" text
            [ def>> fourth ] [ stack-effect in>> ] bi
            pprint-function-args
            ")" text block>
        ]
    } cleave ;

M: alien-callback-type-word definer
    "callback-abi" word-prop "stdcall" =
    \ STDCALL-CALLBACK: \ CALLBACK: ? 
    f ;
M: alien-callback-type-word definition drop f ;
M: alien-callback-type-word synopsis*
    {
        [ seeing-word ]
        [ definer. ]
        [ def>> first pprint-c-type ]
        [ pprint-word ]
        [
            <block "(" text 
            [ def>> second ] [ "callback-effect" word-prop in>> ] bi
            pprint-function-args
            ")" text block>
        ]
    } cleave ;
