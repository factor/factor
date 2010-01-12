! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators
combinators.short-circuit constructors kernel linked-assocs
math math.bitwise random strings uuid ;
IN: bson.constants

: <objid> ( -- objid )
   uuid1 ; inline

TUPLE: oid { a initial: 0 } { b initial: 0 } ;

: <oid> ( -- oid )
    oid new
    now timestamp>micros >>a
    8 random-bits 16 shift HEX: FF0000 mask
    16 random-bits HEX: FFFF mask
    bitor >>b ;

TUPLE: dbref ref id db ;

CONSTRUCTOR: dbref ( ref id -- dbref ) ;

: dbref>assoc ( dbref -- assoc )
    [ <linked-hash> ] dip over
    {
        [ [ ref>> "$ref" ] [ set-at ] bi* ]
        [ [ id>> "$id" ] [ set-at ] bi* ]
        [ over db>> [
                [ db>> "$db" ] [ set-at ] bi*
            ] [ 2drop ] if ]
    } 2cleave ; inline

: assoc>dbref ( assoc -- dbref )
    [ "$ref" swap at ] [ "$id" swap at ] [ "$db" swap at ] tri
    dbref boa ; inline

: dbref-assoc? ( assoc -- ? )
    { [ "$ref" swap key? ] [ "$id" swap key? ] } 1&& ; inline

TUPLE: mdbregexp { regexp string } { options string } ;

: <mdbregexp> ( string -- mdbregexp )
   [ mdbregexp new ] dip >>regexp ;


CONSTANT: MDB_OID_FIELD "_id"
CONSTANT: MDB_META_FIELD "_mfd"

CONSTANT: T_EOO  0  
CONSTANT: T_Double  1  
CONSTANT: T_Integer  16  
CONSTANT: T_Boolean  8  
CONSTANT: T_String  2  
CONSTANT: T_Object  3  
CONSTANT: T_Array  4  
CONSTANT: T_Binary  5  
CONSTANT: T_Undefined  6  
CONSTANT: T_OID  7  
CONSTANT: T_Date  9  
CONSTANT: T_NULL  10  
CONSTANT: T_Regexp  11  
CONSTANT: T_DBRef  12  
CONSTANT: T_Code  13  
CONSTANT: T_ScopedCode  17  
CONSTANT: T_Symbol  14  
CONSTANT: T_JSTypeMax  16  
CONSTANT: T_MaxKey  127  

CONSTANT: T_Binary_Function 1   
CONSTANT: T_Binary_Bytes 2
CONSTANT: T_Binary_UUID 3
CONSTANT: T_Binary_MD5 5
CONSTANT: T_Binary_Custom 128


