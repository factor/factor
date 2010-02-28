! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants calendar combinators
combinators.short-circuit io io.binary kernel math
namespaces sequences serialize strings vectors ;

FROM: io.encodings.binary => binary ;
FROM: io.streams.byte-array => with-byte-reader ;

IN: bson.reader

<PRIVATE

TUPLE: element { type integer } name ;

TUPLE: state
    { size initial: -1 }
    { exemplar assoc }
    result
    { scope vector }
    { elements vector } ;

: (prepare-elements) ( -- elements-vector )
    V{ } clone [ T_Object "" element boa swap push ] [ ] bi ; inline

: <state> ( exemplar -- state )
    [ state new ] dip
    {
        [ clone >>exemplar ]
        [ clone >>result ]
        [ V{ } clone [ push ] keep >>scope ]
    } cleave
    (prepare-elements) >>elements ;

: get-state ( -- state )
    state get ; inline

: read-int32 ( -- int32 )
    4 read signed-le> ; inline

: read-longlong ( -- longlong )
    8 read signed-le> ; inline

: read-double ( -- double )
    8 read le> bits>double ; inline

: read-byte-raw ( -- byte-raw )
    1 read ; inline

: read-byte ( -- byte )
    read-byte-raw first ; inline

: read-cstring ( -- string )
    "\0" read-until drop >string ; inline

: read-sized-string ( length -- string )
    read 1 head-slice* >string ; inline

: push-element ( type name state -- )
    [ element boa ] dip elements>> push ; inline

: pop-element ( state -- element )
    elements>> pop ; inline

: peek-scope ( state -- ht )
    scope>> last ; inline

: bson-object-data-read ( -- object )
    read-int32 drop get-state 
    [ exemplar>> clone ] [ scope>> ] bi
    [ push ] keep ; inline

: bson-binary-bytes? ( subtype -- ? )
    T_Binary_Bytes = ; inline

: bson-binary-read ( -- binary )
   read-int32 read-byte 
   {
        { T_Binary_Bytes [ read ] }
        { T_Binary_Custom [ read bytes>object ] }
        { T_Binary_Function [ read ] }
        [ drop read >string ]
   } case ; inline

: bson-regexp-read ( -- mdbregexp )
   mdbregexp new
   read-cstring >>regexp read-cstring >>options ; inline

: bson-oid-read ( -- oid )
    read-longlong read-int32 oid boa ; inline

: element-data-read ( type -- object )
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

: bson-array? ( type -- ? )
    T_Array = ; inline

: bson-object? ( type -- ? )
    T_Object = ; inline

: check-object ( assoc -- object )
    dup dbref-assoc? [ assoc>dbref ] when ; inline

: fix-result ( assoc type -- result )
    {
        { T_Array [ values ] }
        { T_Object [ check-object ] }
    } case ; inline

: end-element ( type -- )
    { [ bson-object? ] [ bson-array? ] } 1||
    [ get-state pop-element drop ] unless ; inline

: (>state<) ( -- state scope element )
    get-state [  ] [ scope>> ] [ pop-element ] tri ; inline

: (prepare-result) ( scope element -- result )
    [ pop ] [ type>> ] bi* fix-result ; inline

: bson-eoo-element-read ( -- cont? )
    (>state<)
    [ (prepare-result) ] [  ] [ drop empty? ] 2tri
    [ 2drop >>result drop f ]
    [ swap [ name>> ] [ last ] bi* set-at drop t ] if ; inline

: (prepare-object) ( type -- object )
    [ element-data-read ] [ end-element ] bi ; inline

: (read-object) ( type name state -- )
    [ (prepare-object) ] 2dip
    peek-scope set-at ; inline

: bson-not-eoo-element-read ( type -- cont? )
    read-cstring get-state
    [ push-element ]
    [ (read-object) t ] 3bi ; inline

: (element-read) ( type -- cont? )
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
