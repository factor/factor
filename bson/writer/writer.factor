! Copyright (C) 2008 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants 
byte-arrays byte-vectors calendar fry io io.binary io.encodings
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel math math.parser namespaces
quotations sequences serialize strings words ;


IN: bson.writer

#! Writes the object out to a byte-vector in BSON format

<PRIVATE

SYMBOL: shared-buffer 

CONSTANT: INT32-SIZE 4

: (buffer) ( -- buffer )
    shared-buffer get
    [ 4096 <byte-vector> [ shared-buffer set ] keep ] unless* ; inline

PRIVATE>

: ensure-buffer ( -- )
    (buffer) drop ;

: reset-buffer ( -- )
    (buffer) 0 >>length drop ;

: with-buffer ( quot -- byte-vector )
    [ (buffer) ] dip [ output-stream get ] compose
    with-output-stream* dup encoder? [ stream>> ] when ; inline

: with-length ( quot: ( -- ) -- bytes-written start-index )
    [ (buffer) [ length ] keep ] dip call
    length swap [ - ] keep ; inline

: with-length-prefix ( quot: ( -- ) -- )
    [ B{ 0 0 0 0 } write ] prepose with-length
    [ INT32-SIZE >le ] dip (buffer)
    '[ _ over [ nth ] dip _ + _ set-nth ]
    [ INT32-SIZE ] dip each-integer ; inline

<PRIVATE

GENERIC: bson-type? ( obj -- type ) foldable flushable
GENERIC: bson-write ( obj -- )

M: t bson-type? ( boolean -- type ) drop T_Boolean ; 
M: f bson-type? ( boolean -- type ) drop T_Boolean ; 

M: real bson-type? ( real -- type ) drop T_Double ; 
M: word bson-type? ( word -- type ) drop T_String ; 
M: tuple bson-type? ( tuple -- type ) drop T_Object ;  
M: sequence bson-type? ( seq -- type ) drop T_Array ;
M: string bson-type? ( string -- type ) drop T_String ; 
M: integer bson-type? ( integer -- type ) drop T_Integer ; 
M: assoc bson-type? ( assoc -- type ) drop T_Object ;
M: timestamp bson-type? ( timestamp -- type ) drop T_Date ;
M: mdbregexp bson-type? ( regexp -- type ) drop T_Regexp ;

M: oid bson-type? ( word -- type ) drop T_OID ;
M: objid bson-type? ( objid -- type ) drop T_Binary ;
M: objref bson-type? ( objref -- type ) drop T_Binary ;
M: quotation bson-type? ( quotation -- type ) drop T_Binary ; 
M: byte-array bson-type? ( byte-array -- type ) drop T_Binary ; 

: write-byte ( byte -- ) 1 >le write ; inline
: write-int32 ( int -- ) 4 >le write ; inline
: write-double ( real -- ) double>bits 8 >le write ; inline
: write-cstring ( string -- ) utf8 encode B{ 0 } append write ; inline
: write-longlong ( object -- ) 8 >le write ; inline

: write-eoo ( -- ) T_EOO write-byte ; inline
: write-type ( obj -- obj ) [ bson-type? write-byte ] keep ; inline
: write-pair ( name object -- ) write-type [ write-cstring ] dip bson-write ; inline

M: f bson-write ( f -- )
    drop 0 write-byte ; 

M: t bson-write ( t -- )
    drop 1 write-byte ;

M: string bson-write ( obj -- )
    utf8 encode B{ 0 } append
    [ length write-int32 ] keep
    write ;

M: integer bson-write ( num -- )
    write-int32 ;

M: real bson-write ( num -- )
    >float write-double ;

M: timestamp bson-write ( timestamp -- )
    timestamp>millis write-longlong ;

M: byte-array bson-write ( binary -- )
    [ length write-int32 ] keep
    T_Binary_Bytes write-byte
    write ; 

M: quotation bson-write ( quotation -- )
    object>bytes [ length write-int32 ] keep
    T_Binary_Function write-byte
    write ; 

M: oid bson-write ( oid -- )
    [ a>> write-longlong ] [ b>> write-int32 ] bi ;

M: objid bson-write ( oid -- )
    id>> utf8 encode
    [ length write-int32 ] keep
    T_Binary_UUID write-byte
    write ;

M: objref bson-write ( objref -- )
    [ ns>> utf8 encode ]
    [ objid>> id>> utf8 encode ] bi
    append
    [ length write-int32 ] keep
    T_Binary_Custom write-byte
    write ;

M: mdbregexp bson-write ( regexp -- )
   [ regexp>> utf8 encode write-cstring ]
   [ options>> utf8 encode write-cstring ] bi ; 
    
M: sequence bson-write ( array -- )
    '[ _ [ [ write-type ] dip number>string
           write-cstring bson-write ] each-index
       write-eoo ] with-length-prefix ;

: write-oid ( assoc -- )
    [ MDB_OID_FIELD ] dip at*
    [ [ MDB_OID_FIELD ] dip write-pair ] [ drop ] if ; inline

: skip-field? ( name -- boolean )
    { "_id" "_mdb" } member? ; inline

M: assoc bson-write ( assoc -- )
    '[ _  [ write-oid ] keep
       [ over skip-field? [ 2drop ] [ write-pair ] if ] assoc-each
       write-eoo ] with-length-prefix ; 

M: word bson-write name>> bson-write ;

PRIVATE>

: assoc>bv ( assoc -- byte-vector )
    [ '[ _ bson-write ] with-buffer ] with-scope ; inline

: assoc>stream ( assoc -- )
    bson-write ; inline

