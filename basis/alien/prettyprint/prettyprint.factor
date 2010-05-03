! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel combinators alien alien.enums
alien.strings alien.c-types alien.parser alien.syntax arrays
assocs effects math.parser prettyprint.backend prettyprint.custom
prettyprint.sections definitions see see.private sequences
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
M: c-type-word declarations. drop ;

<PRIVATE
GENERIC: pointer-string ( pointer -- string/f )
M: object pointer-string drop f ;
M: word pointer-string name>> ;
M: pointer pointer-string to>> pointer-string [ CHAR: * suffix ] [ f ] if* ;
PRIVATE>

GENERIC: pprint-c-type ( c-type -- )
M: word pprint-c-type pprint-word ;
M: pointer pprint-c-type
    dup pointer-string
    [ swap present-text ]
    [ pprint* ] if* ;
M: wrapper pprint-c-type wrapped>> pprint-word ;
M: string pprint-c-type text ;
M: array pprint-c-type pprint* ;

M: pointer pprint* \ pointer: pprint-word to>> pprint-c-type ;

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

: pprint-library ( library -- )
    [ \ LIBRARY: [ text ] pprint-prefix ] when* ;

: pprint-function ( word quot -- )
    [ def>> first pprint-c-type ]
    swap
    [
        <block "(" text
        [ def>> fourth ] [ stack-effect in>> ] bi
        pprint-function-args
        ")" text block>
    ] tri ; inline

M: alien-function-alias-word definer
    drop \ FUNCTION-ALIAS: \ ; ;
M: alien-function-alias-word definition drop f ;
M: alien-function-alias-word synopsis*
    {
        [ seeing-word ]
        [ def>> second pprint-library ]
        [ definer. ]
        [ pprint-word ]
        [ [ def>> third text ] pprint-function ]
    } cleave ;

M: alien-function-word definer
    drop \ FUNCTION: \ ; ;
M: alien-function-word synopsis*
    {
        [ seeing-word ]
        [ def>> second pprint-library ]
        [ definer. ]
        [ [ pprint-word ] pprint-function ]
    } cleave ;

M: alien-callback-type-word definer
    drop \ CALLBACK: \ ; ;
M: alien-callback-type-word definition drop f ;
M: alien-callback-type-word synopsis*
    {
        [ seeing-word ]
        [ "callback-library" word-prop pprint-library ]
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

M: enum-c-type-word definer
    drop \ ENUM: \ ; ;
M: enum-c-type-word synopsis*
    {
        [ seeing-word ]
        [ definer. ]
        [ pprint-word ]
        [ c-type base-type>> dup int eq? [ drop ] [ "<" text pprint-word ] if ]
    } cleave ;
M: enum-c-type-word definition
    c-type members>> ;
