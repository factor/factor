! Copyright (C) 2008 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants byte-arrays fry io io.binary
io.encodings.binary io.encodings.string io.encodings.utf8
io.streams.byte-array kernel math math.parser quotations sequences
serialize strings words ;

IN: bson.writer

#! Writes the object out to a stream in BSON format

<PRIVATE

GENERIC: bson-type? ( obj -- type )
GENERIC: bson-write ( obj -- )

M: t bson-type? ( boolean -- type ) drop T_Boolean ; 
M: f bson-type? ( boolean -- type ) drop T_Boolean ; 

M: real bson-type? ( real -- type ) drop T_Double ; 
M: word bson-type? ( word -- type ) drop T_String ; 
M: tuple bson-type? ( tuple -- type ) drop T_Object ;  
M: assoc bson-type? ( hashtable -- type ) drop T_Object ; 
M: string bson-type? ( string -- type ) drop T_String ; 
M: integer bson-type? ( integer -- type ) drop T_Integer ; 
M: sequence bson-type? ( seq -- type ) drop T_Array ;

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

M: byte-array bson-write ( binary -- )
    [ length write-int32 ] keep
    T_Binary_Bytes write-byte
    write ; 

M: quotation bson-write ( quotation -- )
    object>bytes [ length write-int32 ] keep
    T_Binary_Function write-byte
    write ; 

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
    
M: sequence bson-write ( array -- )
    '[ _ [ [ write-type ] dip number>string write-cstring bson-write ]
        each-index ]
        binary swap with-byte-writer
        [ length 5 + bson-write ] keep
        write
        write-eoo ; 
    
M: assoc bson-write ( hashtable -- )
    '[ _ [ write-pair ] assoc-each ]
    binary swap with-byte-writer
    [ length 5 + bson-write ] keep
    write
    write-eoo ; 

M: word bson-write name>> bson-write ;

PRIVATE>
    
: assoc>array ( assoc -- byte-array )
    '[ _ bson-write ] binary swap with-byte-writer ; inline

: assoc>stream ( assoc -- )
    bson-write ; inline

