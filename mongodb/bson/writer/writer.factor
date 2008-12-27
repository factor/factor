! Copyright (C) 2008 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: mongodb.bson mongodb.bson.constants accessors kernel io.streams.string
       io.encodings.binary classes byte-arrays quotations serialize
       io.encodings.utf8 strings splitting math.parser locals
       sequences math assocs classes words make fry mongodb.persistent
       prettyprint hashtables mirrors alien.strings alien.c-types
       io.streams.byte-array io ;

IN: mongodb.bson.writer

#! Writes the object out to a stream in BSON format

<PRIVATE

GENERIC: bson-type? ( obj -- type )
GENERIC: bson-write ( obj -- )

M: t bson-type? ( boolean -- type ) drop T_Boolean ;
M: f bson-type? ( boolean -- type ) drop T_Boolean ;

M: oid bson-type? ( word -- type ) drop T_OID ;
M: real bson-type? ( real -- type ) drop T_Double ;
M: word bson-type? ( word -- type ) drop T_String ;
M: tuple bson-type? ( tuple -- type ) drop T_Object ;
M: assoc bson-type? ( hashtable -- type ) drop T_Object ;
M: string bson-type? ( string -- type ) drop T_String ;
M: integer bson-type? ( integer -- type ) drop T_Integer ;
M: sequence bson-type? ( seq -- type ) drop T_Array ;
M: quotation bson-type? ( quotation -- type ) drop T_Binary ;
M: bson-null bson-type? ( null -- type ) drop T_NULL ;
M: byte-array bson-type? ( byte-array -- type ) drop T_Binary ;

: write-byte ( byte -- ) <char> write ;
: write-int32 ( int -- ) <int> write ;
: write-double ( real -- ) <double> write ;
: write-cstring ( string -- ) utf8 string>alien write ;
: write-longlong ( object -- ) <longlong> write ;

: write-eoo ( -- ) T_EOO write-byte ;
: write-type ( obj -- obj ) [ bson-type? write-byte ] keep ;
: write-pair ( name object -- ) write-type [ write-cstring ] dip bson-write ;

:: write-tuple-info ( object -- )
    P_SLOTS [ [ ] [ object at ] bi write-pair ] each ;    

M: f bson-write ( f -- )
    drop 0 write-byte ;

M: t bson-write ( t -- )
    drop 1 write-byte ;

M: bson-null bson-write ( null -- )
    drop ;

M: string bson-write ( obj -- )
    utf8 string>alien 
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

M: oid bson-write ( oid -- )
    [ a>> write-longlong ] [ b>> write-int32 ] bi ;
    
M: sequence bson-write ( array -- )
    '[ _ [ [ write-type ] dip number>string write-cstring bson-write ]
        each-index ]
        binary swap with-byte-writer
        [ length 5 + bson-write ] keep
        write
        write-eoo ;

: check-p-field ( key value -- key value boolean )
    [ [ "_p_" swap start 0 = ] keep ] dip rot ;
    
M: persistent-tuple bson-write ( persistent-tuple -- )
    <mirror>
    '[ _ [ write-tuple-info ]
         [ [ check-p-field [ 2drop ] [ write-pair ] if ] assoc-each ] bi ]
    binary swap with-byte-writer
    [ length 5 + bson-write ] keep
    write
    write-eoo ;

M: tuple bson-write ( tuple -- )
    make-persistent bson-write ;
    
M: assoc bson-write ( hashtable -- )
    '[ _ [ write-pair ] assoc-each ]
    binary swap with-byte-writer
    [ length 5 + bson-write ] keep
    write
    write-eoo ;

M: word bson-write name>> bson-write ;

PRIVATE>

GENERIC: >bson ( obj -- byte-aray )    

M: tuple >bson ( tuble -- byte-array )
    '[ _ bson-write ] binary swap with-byte-writer ;
    
M: hashtable >bson ( hashmap -- byte-array )
    '[ _ bson-write ] binary swap with-byte-writer ;


