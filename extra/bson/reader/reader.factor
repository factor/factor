! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants calendar combinators
combinators.short-circuit fry io io.binary kernel locals math
namespaces sequences serialize tools.continuations strings ;
FROM: io.encodings.binary => binary ;
FROM: io.streams.byte-array => with-byte-reader ;
IN: bson.reader

<PRIVATE

TUPLE: element { type integer } name ;
TUPLE: state
    { size initial: -1 } exemplar
    result scope element ;

: <state> ( exemplar -- state )
    [ state new ] dip
    [ clone >>exemplar ] keep
    clone [ >>result ] [ V{ } clone [ push ] keep >>scope ] bi
    V{ } clone [ T_Object "" element boa swap push ] keep >>element ; 

PREDICATE: bson-not-eoo < integer T_EOO > ;
PREDICATE: bson-eoo     < integer T_EOO = ;

PREDICATE: bson-string  < integer T_String = ;
PREDICATE: bson-object  < integer T_Object = ;
PREDICATE: bson-oid     < integer T_OID = ;
PREDICATE: bson-array   < integer T_Array = ;
PREDICATE: bson-integer < integer T_Integer = ;
PREDICATE: bson-double  < integer T_Double = ;
PREDICATE: bson-date    < integer T_Date = ;
PREDICATE: bson-binary  < integer T_Binary = ;
PREDICATE: bson-boolean < integer T_Boolean = ;
PREDICATE: bson-regexp  < integer T_Regexp = ;
PREDICATE: bson-null    < integer T_NULL = ;
PREDICATE: bson-ref     < integer T_DBRef = ;
PREDICATE: bson-binary-bytes < integer T_Binary_Bytes = ;
PREDICATE: bson-binary-function < integer T_Binary_Function = ;
PREDICATE: bson-binary-uuid < integer T_Binary_UUID = ;
PREDICATE: bson-binary-custom < integer T_Binary_Custom = ;

: get-state ( -- state )
    state get ; inline

: read-int32 ( -- int32 )
    4 read signed-le> ; inline

: read-longlong ( -- longlong )
    8 read signed-le> ; inline

: read-double ( -- double )
    8 read le> bits>double ; inline

: read-byte-raw ( -- byte-raw )
    1 read ;

: read-byte ( -- byte )
    read-byte-raw first ; inline

: read-cstring ( -- string )
    "\0" read-until drop >string ; inline

: read-sized-string ( length -- string )
    read 1 head-slice* >string ; inline

: read-element-type ( -- type )
    read-byte ; inline

: push-element ( type name -- )
    element boa get-state element>> push ; inline

: pop-element ( -- element )
    get-state element>> pop ; inline

: peek-scope ( -- ht )
    get-state scope>> last ; inline

: bson-object-data-read ( -- object )
    read-int32 drop get-state 
    [ exemplar>> clone ] [ scope>> ] bi
    [ push ] keep ; inline

: bson-binary-read ( -- binary )
   read-int32 read-byte 
   bson-binary-bytes? [ read ] [ read bytes>object ] if ; inline

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

: fix-result ( assoc type -- result )
    {
        { [ dup T_Array = ] [ drop values ] }
        {
            [ dup T_Object = ]
            [ drop dup dbref-assoc? [ assoc>dbref ] when ]
        }
    } cond ; inline

: end-element ( type -- )
    { [ bson-object? ] [ bson-array? ] } 1||
    [ pop-element drop ] unless ; inline

:: bson-eoo-element-read ( type -- cont? )
    pop-element :> element
    get-state scope>>
    [ pop element type>> fix-result ] [ empty? ] bi
    [ [ get-state ] dip >>result drop f ]
    [ element name>> peek-scope set-at t ] if ; inline

:: bson-not-eoo-element-read ( type -- cont? )
    peek-scope :> scope
    type read-cstring [ push-element ] 2keep
    [ [ element-data-read ] [ end-element ] bi ]
    [ scope set-at t ] bi* ; inline

: (element-read) ( type -- cont? )
    dup bson-not-eoo? 
    [ bson-not-eoo-element-read ]
    [ bson-eoo-element-read ] if ; inline

: read-elements ( -- )
    read-element-type
    (element-read) [ read-elements ] when ; inline recursive

PRIVATE>

: stream>assoc ( exemplar -- assoc )
    <state> dup state
    [ read-int32 >>size read-elements ] with-variable
    result>> ; inline
