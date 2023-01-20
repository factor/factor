! Copyright (C) 2010 Anton Gorenko.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii combinators gobject-introspection.common
gobject-introspection.repository kernel literals math.parser
sequences splitting xml.data xml.traversal ;
IN: gobject-introspection.loader

: xml>simple-type ( xml -- type )
    [ simple-type new ] dip {
        [ "name" attr >>name ]
        [
            "type" tags-named
            [ xml>simple-type ] map f like >>element-types
        ]
    } cleave ;

: xml>varargs-type ( xml -- type )
    drop varargs-type new ;

: xml>array-type ( xml -- type )
    [ array-type new ] dip {
        [ "name" attr >>name ]
        [ "zero-terminated" attr "0" = not >>zero-terminated? ]
        [ "length" attr string>number >>length ]
        [ "fixed-size" attr string>number >>fixed-size ]
        [ "type" tag-named xml>simple-type >>element-type ]
    } cleave ;

: xml>inner-callback-type ( xml -- type )
    [ inner-callback-type new ] dip {
        [ "name" attr >>name ]
    } cleave ;

: xml>type ( xml -- type )
    dup name>> main>> {
        { "type" [ xml>simple-type ] }
        { "array" [ xml>array-type ] }
        { "callback" [ xml>inner-callback-type ] }
        { "varargs" [ xml>varargs-type ] }
    } case ;

CONSTANT: type-tags
    $[ { "array" "type" "callback" "varargs" } [ <null-name> ] map ]

: child-type-tag ( xml -- type-tag )
    children-tags [
        type-tags [ swap tag-named? ] with any?
    ] find nip ;

: xml>alias ( xml -- alias )
    [ alias new ] dip {
        [ "name" attr >>name ]
        [ "type" attr >>c-type ]
        [ child-type-tag xml>type >>type ]
    } cleave ;

: xml>const ( xml -- const )
    [ const new ] dip {
        [ "name" attr >>name ]
        [ "value" attr >>value ]
        [ child-type-tag xml>type >>type ]
    } cleave ;

: load-type ( type xml -- type )
    {
        [ "name" attr >>name ]
        [ [ "type" attr ] [ "type-name" attr ] bi or >>c-type ]
        [ "get-type" attr >>get-type ]
    } cleave ;

: xml>member ( xml -- member )
    [ enum-member new ] dip {
        [ "name" attr >>name ]
        [ "identifier" attr >>c-identifier ]
        [ "value" attr string>number >>value ]
    } cleave ;

: xml>enum ( xml -- enum )
    [ enum new ] dip {
        [ load-type ]
        [ "member" tags-named [ xml>member ] map >>members ]
    } cleave ;

: load-parameter ( param xml -- param )
    [ child-type-tag xml>type >>type ]
    [ "transfer-ownership" attr >>transfer-ownership ] bi ;

: xml>parameter ( xml -- parameter )
    [ parameter new ] dip {
        [ "name" attr >>name ]
        [ "direction" attr dup "in" ? >>direction ]
        [ "allow-none" attr "1" = >>allow-none? ]
        [ child-type-tag xml>type >>type ]
        [ "transfer-ownership" attr >>transfer-ownership ]
    } cleave ;

: xml>return ( xml -- return )
    [ return new ] dip {
        [ child-type-tag xml>type >>type ]
        [ "transfer-ownership" attr >>transfer-ownership ]
    } cleave ;

: load-callable ( callable xml -- callable )
    [ "return-value" tag-named xml>return >>return ]
    [
        "parameters" tag-named "parameter" tags-named
        [ xml>parameter ] map >>parameters
    ] bi ;

: xml>function ( xml -- function )
    [ function new ] dip {
        [ "name" attr >>name ]
        [ "identifier" attr >>identifier ]
        [ load-callable ]
        [ "throws" attr "1" = >>throws? ]
    } cleave ;

: load-functions ( xml tag-name -- functions )
    tags-named [ xml>function ] map ;

: xml>field ( xml -- field )
    [ field new ] dip {
        [ "name" attr >>name ]
        [ "writable" attr "1" = >>writable? ]
        [ "bits" attr string>number >>bits ]
        [ child-type-tag xml>type >>type ]
    } cleave ;

: xml>record ( xml -- record )
    [ record new ] dip {
        [ load-type ]
        [
            over c-type>> implement-struct?
            [ "field" tags-named [ xml>field ] map >>fields ]
            [ drop ] if
        ]
        [ "constructor" load-functions >>constructors ]
        [ "method" load-functions >>methods ]
        [ "function" load-functions >>functions ]
        [ "disguised" attr "1" = >>disguised? ]
        [ "is-gtype-struct-for" attr >>struct-for ]
    } cleave ;

: xml>union ( xml -- union )
    [ union new ] dip {
        [ load-type ]
        [ "field" tags-named [ xml>field ] map >>fields ]
        [ "constructor" load-functions >>constructors ]
        [ "method" load-functions >>methods ]
        [ "function" load-functions >>functions ]
    } cleave ;

: xml>callback ( xml -- callback )
    [ callback new ] dip {
        [ load-type ]
        [ load-callable ]
        [ "throws" attr "1" = >>throws? ]
    } cleave ;

: xml>signal ( xml -- signal )
    [ signal new ] dip {
        [ "name" attr >>name ]
        [ load-callable ]
    } cleave ;

: xml>property ( xml -- property )
    [ property new ] dip {
        [ "name" attr >>name ]
        [ "writable" attr "1" = >>writable? ]
        [ "readable" attr "0" = not >>readable? ]
        [ "construct" attr "1" = >>construct? ]
        [ "construct-only" attr "1" = >>construct-only? ]
        [ child-type-tag xml>type >>type ]
    } cleave ;

: xml>class ( xml -- class )
    [ class new ] dip {
        [ load-type ]
        [ "abstract" attr "1" = >>abstract? ]
        [ "parent" attr >>parent ]
        [ "type-struct" attr >>type-struct ]
        [ "constructor" load-functions >>constructors ]
        [ "method" load-functions >>methods ]
        [ "function" load-functions >>functions ]
        [ "signal" tags-named [ xml>signal ] map >>signals ]
    } cleave ;

: xml>interface ( xml -- interface )
    [ interface new ] dip {
        [ load-type ]
        [ "method" load-functions >>methods ]
        [ "function" load-functions >>functions ]
        [ "signal" tags-named [ xml>signal ] map >>signals ]
    } cleave ;

: xml>boxed ( xml -- boxed )
    [ boxed new ] dip
        load-type ;

: fix-conts ( namespace -- )
    [ symbol-prefixes>> first >upper "_" append ] [ consts>> ] bi
    [ [ name>> append ] keep c-identifier<< ] with each ;

: postprocess-namespace ( namespace -- )
    fix-conts ;

: xml>namespace ( xml -- namespace )
    [ namespace new ] dip {
        [ "name" attr >>name ]
        [ "identifier-prefixes" attr "," split >>identifier-prefixes ]
        [ "symbol-prefixes" attr "," split >>symbol-prefixes ]
        [ "alias" tags-named [ xml>alias ] map >>aliases ]
        [ "constant" tags-named [ xml>const ] map >>consts ]
        [ "enumeration" tags-named [ xml>enum ] map >>enums ]
        [ "bitfield" tags-named [ xml>enum ] map >>bitfields ]
        [ "record" tags-named [ xml>record ] map >>records ]
        [ "union" tags-named [ xml>union ] map >>unions ]
        [ "boxed" tags-named [ xml>boxed ] map >>boxeds ]
        [ "callback" tags-named [ xml>callback ] map >>callbacks ]
        [ "class" tags-named [ xml>class ] map >>classes ]
        [ "interface" tags-named [ xml>interface ] map >>interfaces ]
        [ "function" load-functions >>functions ]
    } cleave [ postprocess-namespace ] keep ;

: xml>repository ( xml -- repository )
    [ repository new ] dip
    "namespace" tag-named xml>namespace >>namespace ;
