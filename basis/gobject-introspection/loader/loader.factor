! Copyright (C) 2009 Anton Gorenko.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors ascii combinators fry
gobject-introspection.common gobject-introspection.repository
gobject-introspection.types kernel math.parser sequences
splitting xml.data xml.traversal ;
FROM: namespaces => set get ;
IN: gobject-introspection.loader

SYMBOL: namespace-prefix
SYMBOL: namespace-PREFIX

: word-started? ( word letter -- ? )
    [ last letter? ] [ LETTER? ] bi* and ;

: camel>PREFIX ( name -- name' )
    dup 1 head
    [ 2dup word-started? [ [ CHAR: _ suffix ] dip ] when suffix ]
    reduce rest >upper ;

: set-prefix ( prefix -- )
    [ namespace-prefix set ]
    [ camel>PREFIX namespace-PREFIX set ] bi ;

: camel>factor ( name -- name' )
    dup 1 head
    [ 2dup word-started? [ [ CHAR: - suffix ] dip ] when suffix ]
    reduce rest >lower ;

: underscored>factor ( name -- name' )
    [ [ CHAR: _ = not ] keep CHAR: - ? ] map >lower ;

: full-type-name>type ( name -- type )
    [ type new ] dip
    camel>factor "." split1 dup [ swap ] unless
    [ >>namespace ] [ >>name ] bi* absolute-type ;

: node>type ( xml -- type )
    "name" attr full-type-name>type ;

: xml>array-info ( xml -- array-info )
    [ array-info new ] dip {
        [ "zero-terminated" attr [ "1" = ] [ t ] if* >>zero-terminated? ]
        [ "length" attr [ string>number ] [ f ] if* >>length ]
        [ "fixed-size" attr [ string>number ] [ f ] if* >>fixed-size ]
    } cleave ;

: xml>type ( xml -- array-info type )
    dup name>> main>> {
        { "array"
            [
                [ xml>array-info ]
                [ first-child-tag node>type ] bi
            ]
        }
        { "type" [ node>type f swap ] }
        { "varargs" [ drop f f ] }
        { "callback" [ drop f "any" f type boa ] }
    } case ;
    
: load-parameter ( param xml -- param )
    [ "transfer-ownership" attr >>transfer-ownership ]
    [ first-child-tag "type" attr >>c-type ]
    [
        first-child-tag xml>type
        [ [ >>array-info ] [ >>type ] bi* ] [ 2drop f ] if*
    ] tri ;

: load-type ( type xml -- type )
    {
        [ "name" attr camel>factor >>name ]
        [ node>type >>type ]
        [ "type" attr >>c-type ]
        [ "type-name" attr >>type-name ]
        [ "get-type" attr >>get-type ]
    } cleave ;

: xml>parameter ( xml -- parameter )
    [ parameter new ] dip {
        [ "name" attr >>name ]
        [ "direction" attr dup "in" ? >>direction ]
        [ "allow-none" attr "1" = >>allow-none? ]
        [ load-parameter ]
    } cleave ;

: xml>return ( xml -- return )
    [ return new ] dip {
        [ drop "result" >>name ]
        [ load-parameter ]
    } cleave ;

: throws-parameter ( -- parameter )
    parameter new
        "error" >>name
        "in" >>direction
        "none" >>transfer-ownership
        "GError**" >>c-type
        "GLib.Error" full-type-name>type >>type ;

: extract-parameters ( xml -- parameters )
    "parameters" tag-named "parameter" tags-named
    [ xml>parameter ] map ;

: load-parameters ( callable xml -- callable )
    [
        [
            extract-parameters
            dup { f } tail? [ but-last [ t >>varargs? ] dip ] when
        ]
        [ "throws" attr "1" = [ throws-parameter suffix ] when ] bi
        >>parameters
    ]
    [ "return-value" tag-named xml>return >>return ] bi ;

: xml>function ( xml -- function )
    [ function new ] dip {
        [ "name" attr underscored>factor >>name ]
        [ "identifier" attr >>identifier ]
        [ load-parameters ]
    } cleave ;

: (type>param) ( type -- param )
    [ parameter new ] dip
    [ c-type>> CHAR: * suffix >>c-type ] [ type>> >>type ] bi
    "none" >>transfer-ownership
    "in" >>direction ;
    
: type>self-param ( type -- self )
    (type>param) "self" >>name ;

: type>sender-param ( type -- sender )
    (type>param) "sender" >>name ;

: signal-data-param ( -- param )
    parameter new
    "user_data" >>name
    "gpointer" >>c-type
    type new "any" >>name >>type
    "none" >>transfer-ownership
    "in" >>direction ;

: xml>property ( xml -- property )
     [ property new ] dip {
        [ "name" attr >>name ]
        [ "writable" attr "1" = >>writable? ]
        [ "readable" attr "0" = not >>readable? ]
        [ "construct" attr "1" = >>construct? ]
        [ "construct-only" attr "1" = >>construct-only? ]
        [ first-child-tag xml>type nip >>type ]
    } cleave ;

: xml>callback ( xml -- callback )
    [ callback new ] dip {
        [ load-type ]
        [ load-parameters ]
    } cleave ;

: xml>signal ( xml -- signal )
    [ signal new ] dip {
        [ "name" attr camel>factor >>name ]
        [ node>type >>type ]
        [ "type" attr >>c-type ]
        [
            load-parameters
            [ signal-data-param suffix ] change-parameters
        ]
    } cleave ;

: load-functions ( xml tag-name -- functions )
    tags-named [ xml>function ] map ;

: xml>class ( xml -- class )
    [ class new ] dip {
        [ load-type ]
        [ "abstract" attr "1" = >>abstract? ]
        [
            "parent" attr [ full-type-name>type ] [ f ] if*
            >>parent
        ]
        [ "type-struct" attr >>type-struct ]
        [ "constructor" load-functions >>constructors ]
        [ "function" load-functions >>functions ]
        [
            "method" load-functions over type>self-param
            '[ [ _ prefix ] change-parameters ] map
            >>methods
        ]       
        [
            "signal" tags-named [ xml>signal ] map
            over type>sender-param
            '[ [ _ prefix ] change-parameters ] map
            over c-type>> CHAR: : suffix
            '[ dup name>> _ prepend >>c-type ] map
            >>signals
        ]
    } cleave ;

: xml>interface ( xml -- interface )
    [ interface new ] dip {
        [ load-type ]
        [
            "method" load-functions over type>self-param
            '[ [ _ prefix ] change-parameters ] map
            >>methods
        ] 
    } cleave ;

: xml>member ( xml -- member )
    [ enum-member new ] dip {
        [ "name" attr underscored>factor >>name ]
        [ "identifier" attr >>c-identifier ]
        [ "value" attr string>number >>value ]
    } cleave ;

: xml>enum ( xml -- enum )
    [ enum new ] dip {
        [ load-type ]
        [ "member" tags-named [ xml>member ] map >>members ]
    } cleave ;

: xml>field ( xml -- field )
    [ field new ] dip {
        [ "name" attr >>name ]
        [ "writable" attr "1" = >>writable? ]
        [
            first-child-tag dup name>> main>> "callback" =
            [ drop "gpointer" ] [ "type" attr ] if
            >>c-type
        ]
        [
            first-child-tag xml>type
            [ [ >>array-info ] [ >>type ] bi* ] [ 2drop f ] if*
        ]
    } cleave ;

: xml>record ( xml -- record )
    [ record new ] dip {
        [ load-type ]
        [ "disguised" attr "1" = >>disguised? ]
        [ "field" tags-named [ xml>field ] map >>fields ]
        [ "constructor" load-functions >>constructors ]
        [ "function" load-functions >>functions ]
        [
            "method" load-functions over type>self-param
            '[ [ _ prefix ] change-parameters ] map
            >>methods
        ]
    } cleave ;

: xml>union ( xml -- union )
    [ union new ] dip load-type ;

: xml>alias ( xml -- alias )
    [ alias new ] dip {
        [ node>type >>name ]
        [ "target" attr full-type-name>type >>target ]
    } cleave ;

: xml>const ( xml -- const )
    [ const new ] dip {
        [ "name" attr >>name ]
        [
            "name" attr namespace-PREFIX get swap "_" glue
            >>c-identifier
        ]
        [ "value" attr >>value ]
        [ first-child-tag "type" attr >>c-type ]
        [ first-child-tag xml>type nip >>type ]
    } cleave ;

: xml>namespace ( xml -- namespace )
    [ namespace new ] dip {
        [ "name" attr camel>factor >>name ]
        [ "prefix" attr [ set-prefix ] keep >>prefix ]
        [ "alias" tags-named [ xml>alias ] map >>aliases ]
        [ "record" tags-named [ xml>record ] map >>records ]
        [ "union" tags-named [ xml>union ] map >>unions ]
        [ "callback" tags-named [ xml>callback ] map >>callbacks ]
        [ "interface" tags-named [ xml>interface ] map >>interfaces ]
        [ "class" tags-named [ xml>class ] map >>classes ]
        [ "constant" tags-named [ xml>const ] map >>consts ]
        [ "enumeration" tags-named [ xml>enum ] map >>enums ]
        [ "bitfield" tags-named [ xml>enum ] map >>bitfields ]
        [ "function" load-functions >>functions ]
    } cleave ;

: xml>repository ( xml -- repository )
    [ repository new ] dip {
        [
            "" "include" f <name> tags-named
            [ "name" attr camel>factor ] map >>includes
        ]
        [ "namespace" tag-named xml>namespace >>namespace ]
    } cleave ;

