! Copyright (C) 2008 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: mongodb.bson mongodb.bson.constants accessors kernel io.streams.string io.encodings.binary
       io.encodings.utf8 strings splitting math.parser
       sequences math assocs classes words make fry 
       prettyprint hashtables mirrors bson alien.strings alien.c-types
       io.streams.byte-array io ;

IN: mongodb.bson.writer

<PRIVATE

#! Returns BSON type
GENERIC: bson-type? ( obj -- type )

M: t bson-type? ( boolean -- type )
    drop T_Boolean ;
M: f bson-type? ( boolean -- type )
    drop T_Boolean ;
M: bson-null bson-type? ( null -- type )
    drop T_NULL ;
M: string bson-type? ( string -- type )
    drop T_String ;
M: integer bson-type? ( integer -- type )
    drop T_Integer ;
M: real bson-type? ( real -- type )
    drop T_Double ;
M: sequence bson-type? ( seq -- type )
    drop T_Array ;
M: tuple bson-type? ( tuple -- type )
    drop T_Object ;
M: hashtable bson-type? ( hashtable -- type )
    drop T_Object ;
M: word bson-type? ( word -- type )
    drop T_String ;

: write-type ( obj -- obj )
    [ bson-type? <char> write ] keep ;

: write-cstring ( string -- )
    utf8 string>alien write ;

PRIVATE>

#! Writes the object out to a stream in BSON format
GENERIC: bson-print ( obj -- )

: (>bson) ( obj -- byte-array )
    '[ _ bson-print ] binary swap with-byte-writer ;

GENERIC: >bson ( obj -- byte-aray )    

M: tuple >bson ( tuble -- byte-array )
    (>bson) ;
    
M: hashtable >bson ( hashmap -- byte-array )
    (>bson) ;

M: f bson-print ( f -- )
    drop 0 <char> write ;

M: t bson-print ( t -- )
    drop 1 <char> write ;

M: bson-null bson-print ( null -- )
    drop ;

M: string bson-print ( obj -- )
    utf8 string>alien 
    [ length <int> write ] keep
    write ;

M: integer bson-print ( num -- )
    <int> write ;

M: real bson-print ( num -- )
    >float <double>  write ;

M: sequence bson-print ( array -- )
    '[ _ [ [ write-type ] dip number>string write-cstring bson-print ]
        each-index ]
    binary swap with-byte-writer
    [ length 5 + bson-print ] keep
    write
    T_EOO write ;


M: tuple bson-print ( tuple -- )
    <mirror> '[ _ [ write-type [ write-cstring ] dip bson-print ] assoc-each ]
        binary swap with-byte-writer
        [ length 5 + bson-print ] keep write
        T_EOO bson-print ;
    
M: hashtable bson-print ( hashtable -- )
    '[ _ [ write-type [ write-cstring ] dip bson-print ] assoc-each ]
        binary swap with-byte-writer
        [ length 5 + bson-print ] keep write
        T_EOO bson-print ;

M: word bson-print name>> bson-print ;
