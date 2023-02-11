! Copyright (C) 2008, 2010 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.enums alien.strings
alien.syntax arrays assocs combinators combinators.short-circuit
definitions effects kernel math.parser prettyprint.backend
prettyprint.custom prettyprint.sections see see.private sequences
words ;
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
GENERIC: record-pointer ( pointer -- )
M: object record-pointer drop ;
M: word record-pointer record-vocab ;
M: pointer record-pointer to>> record-pointer ;

GENERIC: record-c-type ( c-type -- )
M: word record-c-type record-vocab ;
M: pointer record-c-type record-pointer ;
M: wrapper record-c-type wrapped>> record-c-type ;
M: array record-c-type first record-c-type ;
PRIVATE>

: pprint-c-type ( c-type -- )
    [ record-c-type ] [ c-type-string ] [ ] tri present-text ;

M: pointer pprint*
    <flow \ pointer: pprint-word to>> pprint* block> ;

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

PREDICATE: alien-function-alias-word < word
    def>> {
        [ length 6 = ]
        [ last \ alien-invoke eq? ]
    } 1&& ;

M: alien-function-alias-word definer
    drop \ FUNCTION-ALIAS: f ;
M: alien-function-alias-word definition drop f ;
M: alien-function-alias-word synopsis*
    {
        [ seeing-word ]
        [ def>> second pprint-library ]
        [ definer. ]
        [ pprint-word ]
        [ [ def>> third text ] pprint-function ]
    } cleave ;
M: alien-function-alias-word declarations. drop ;

PREDICATE: alien-function-word < alien-function-alias-word
    [ def>> third ] [ name>> ] bi = ;

M: alien-function-word definer
    drop \ FUNCTION: f ;
M: alien-function-word synopsis*
    {
        [ seeing-word ]
        [ def>> second pprint-library ]
        [ definer. ]
        [ [ pprint-word ] pprint-function ]
    } cleave ;

PREDICATE: alien-callback-type-word < typedef-word
    "callback-effect" word-prop >boolean ;

M: alien-callback-type-word definer
    drop \ CALLBACK: f ;
M: alien-callback-type-word definition drop f ;
M: alien-callback-type-word synopsis*
    {
        [ seeing-word ]
        [ "callback-library" word-prop pprint-library ]
        [ definer. ]
        [ def>> first first pprint-c-type ]
        [ pprint-word ]
        [
            <block "(" text
            [ def>> first second ] [ "callback-effect" word-prop in>> ] bi
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
        [ lookup-c-type base-type>> dup int eq? [ drop ] [ "<" text pprint-word ] if ]
    } cleave ;
M: enum-c-type-word definition
    lookup-c-type members>> ;
