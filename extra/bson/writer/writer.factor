! Copyright (C) 2008 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants byte-arrays byte-vectors
calendar fry io io.binary io.encodings io.encodings.binary
io.encodings.utf8 io.streams.byte-array kernel math math.parser
namespaces quotations sequences sequences.private serialize strings
words combinators.short-circuit literals ;

IN: bson.writer

<PRIVATE

SYMBOL: shared-buffer 

CONSTANT: INT32-SIZE 4
CONSTANT: CHAR-SIZE 1
CONSTANT: INT64-SIZE 8

: (buffer) ( -- buffer )
    shared-buffer get
    [ 8192 <byte-vector> [ shared-buffer set ] keep ] unless* ; inline

: >le-stream ( x n -- )
    swap
    '[ _ swap nth-byte 0 B{ 0 }
       [ set-nth-unsafe ] keep write ] each ; inline

PRIVATE>

: reset-buffer ( buffer -- )
    0 >>length drop ; inline

: ensure-buffer ( -- )
    (buffer) drop ; inline

: with-buffer ( quot -- byte-vector )
    [ (buffer) [ reset-buffer ] keep dup ] dip
    with-output-stream* dup encoder? [ stream>> ] when ; inline

: with-length ( quot: ( -- ) -- bytes-written start-index )
    [ (buffer) [ length ] keep ] dip call
    length swap [ - ] keep ; inline

: with-length-prefix ( quot: ( -- ) -- )
    [ B{ 0 0 0 0 } write ] prepose with-length
    [ INT32-SIZE >le ] dip (buffer)
    '[ _ over [ nth-unsafe ] dip _ + _ set-nth-unsafe ]
    [ INT32-SIZE ] dip each-integer ; inline

: with-length-prefix-excl ( quot: ( -- ) -- )
    [ B{ 0 0 0 0 } write ] prepose with-length
    [ INT32-SIZE - INT32-SIZE >le ] dip (buffer)
    '[ _ over [ nth-unsafe ] dip _ + _ set-nth-unsafe ]
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
M: objref bson-type? ( objref -- type ) drop T_Binary ;
M: quotation bson-type? ( quotation -- type ) drop T_Binary ; 
M: byte-array bson-type? ( byte-array -- type ) drop T_Binary ; 

: write-utf8-string ( string -- )
    output-stream get utf8 <encoder> stream-write ; inline

: write-byte ( byte -- ) CHAR-SIZE >le-stream ; inline
: write-int32 ( int -- ) INT32-SIZE >le-stream ; inline
: write-double ( real -- ) double>bits INT64-SIZE >le-stream ; inline
: write-cstring ( string -- ) write-utf8-string 0 write-byte ; inline
: write-longlong ( object -- ) INT64-SIZE >le-stream ; inline

: write-eoo ( -- ) T_EOO write-byte ; inline
: write-type ( obj -- obj ) [ bson-type? write-byte ] keep ; inline
: write-pair ( name object -- ) write-type [ write-cstring ] dip bson-write ; inline

M: f bson-write ( f -- )
    drop 0 write-byte ; 

M: t bson-write ( t -- )
    drop 1 write-byte ;

M: string bson-write ( obj -- )
    '[ _ write-cstring ] with-length-prefix-excl ;

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

M: objref bson-write ( objref -- )
    [ binary ] dip
    '[ _
       [ ns>> write-cstring ]
       [ objid>> write-cstring ] bi ] with-byte-writer
    [ length write-int32 ] keep
    T_Binary_Custom write-byte write ;
       
M: mdbregexp bson-write ( regexp -- )
   [ regexp>> write-cstring ]
   [ options>> write-cstring ] bi ; 
    
M: sequence bson-write ( array -- )
    '[ _ [ [ write-type ] dip number>string
           write-cstring bson-write ] each-index
       write-eoo ] with-length-prefix ;

: write-oid ( assoc -- )
    [ MDB_OID_FIELD ] dip at
    [ [ MDB_OID_FIELD ] dip write-pair ] when* ; inline

: skip-field? ( name -- boolean )
   { $[ MDB_OID_FIELD MDB_META_FIELD ] } member? ; inline

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

: mdb-special-value? ( value -- ? )
   { [ timestamp? ] [ quotation? ] [ mdbregexp? ]
     [ oid? ] [ byte-array? ] } 1|| ;