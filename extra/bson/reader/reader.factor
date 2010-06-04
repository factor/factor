! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants calendar combinators
combinators.short-circuit io io.binary kernel math locals
namespaces sequences serialize strings vectors byte-arrays ;

FROM: io.encodings.binary => binary ;
FROM: io.streams.byte-array => with-byte-reader ;
FROM: typed => TYPED: ;

IN: bson.reader

<PRIVATE

TUPLE: element { type integer } name ;

TUPLE: state
    { size initial: -1 }
    { exemplar assoc }
    result
    { scope vector }
    { elements vector } ;

TYPED: (prepare-elements) ( -- elements-vector: vector )
    V{ } clone [ T_Object "" element boa swap push ] [ ] bi ; inline

: <state> ( exemplar -- state )
    [ state new ] dip
    {
        [ clone >>exemplar ]
        [ clone >>result ]
        [ V{ } clone [ push ] keep >>scope ]
    } cleave
    (prepare-elements) >>elements ;

TYPED: get-state ( -- state: state )
    state get ; inline

TYPED: read-int32 ( -- int32: integer )
    4 read signed-le> ; inline

TYPED: read-longlong ( -- longlong: integer )
    8 read signed-le> ; inline

TYPED: read-double ( -- double: float )
    8 read le> bits>double ; inline

TYPED: read-byte-raw ( -- byte-raw: byte-array )
    1 read ; inline

TYPED: read-byte ( -- byte: integer )
    read-byte-raw first ; inline

TYPED: read-cstring ( -- string: string )
    "\0" read-until drop >string ; inline

TYPED: read-sized-string ( length: integer -- string: string )
    read 1 head-slice* >string ; inline

TYPED: push-element ( type: integer name: string state: state -- )
    [ element boa ] dip elements>> push ; inline

TYPED: pop-element ( state: state -- element: element )
    elements>> pop ; inline

TYPED: peek-scope ( state: state -- ht )
    scope>> last ; inline

: bson-object-data-read ( -- object )
    read-int32 drop get-state 
    [ exemplar>> clone dup ] [ scope>> ] bi push ; inline

: bson-binary-read ( -- binary )
   read-int32 read-byte 
   {
        { T_Binary_Bytes [ read ] }
        { T_Binary_Custom [ read bytes>object ] }
        { T_Binary_Function [ read ] }
        [ drop read >string ]
   } case ; inline

TYPED: bson-regexp-read ( -- mdbregexp: mdbregexp )
   mdbregexp new
   read-cstring >>regexp read-cstring >>options ; inline

TYPED: bson-oid-read ( -- oid: oid )
    read-longlong read-int32 oid boa ; inline

TYPED: element-data-read ( type: integer -- object )
    {
        { T_OID [ bson-oid-read ] }
        { T_String [ read-int32 read-sized-string ] }
        { T_Integer [ read-int32 ] }
        { T_Binary [ bson-binary-read ] }
        { T_Object [ bson-object-data-read ] }
        { T_Array [ bson-object-data-read ] }
        { T_Double [ read-double ] }
        { T_Boolean [ read-byte 1 = ] }
        { T_Date [ read-longlong millis>timestamp ] }
        { T_Regexp [ bson-regexp-read ] }
        { T_NULL [ f ] }
    } case ; inline

TYPED: bson-array? ( type: integer -- ?: boolean )
    T_Array = ; inline

TYPED: bson-object? ( type: integer -- ?: boolean )
    T_Object = ; inline

: check-object ( assoc -- object )
    dup dbref-assoc? [ assoc>dbref ] when ; inline

TYPED: fix-result ( assoc type: integer -- result )
    {
        { T_Array [ values ] }
        { T_Object [ check-object ] }
    } case ; inline

TYPED: end-element ( type: integer -- )
    { [ bson-object? ] [ bson-array? ] } 1||
    [ get-state pop-element drop ] unless ; inline

TYPED: (>state<) ( -- state: state scope: vector element: element )
    get-state [  ] [ scope>> ] [ pop-element ] tri ; inline

TYPED: (prepare-result) ( scope: vector element: element -- result )
    [ pop ] [ type>> ] bi* fix-result ; inline

: bson-eoo-element-read ( -- cont?: boolean )
    (>state<)
    [ (prepare-result) ] [  ] [ drop empty? ] 2tri
    [ 2drop >>result drop f ]
    [ swap [ name>> ] [ last ] bi* set-at drop t ] if ; inline

TYPED: (prepare-object) ( type: integer -- object )
    [ element-data-read ] [ end-element ] bi ; inline

:: (read-object) ( type name state -- )
    state peek-scope :> scope
    type (prepare-object) name scope set-at ; inline

TYPED: bson-not-eoo-element-read ( type: integer -- cont?: boolean )
    read-cstring get-state
    [ push-element ]
    [ (read-object) t ] 3bi ; inline

TYPED: (element-read) ( type: integer -- cont?: boolean )
    dup T_EOO > 
    [ bson-not-eoo-element-read ]
    [ drop bson-eoo-element-read ] if ; inline

: read-elements ( -- )
    read-byte (element-read)
    [ read-elements ] when ; inline recursive

PRIVATE>

: stream>assoc ( exemplar -- assoc )
    <state> read-int32 >>size
    [ state [ read-elements ] with-variable ]
    [ result>> ] bi ;
