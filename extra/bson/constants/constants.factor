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

TUPLE: mongo-timestamp incr seconds ;

: <mongo-timestamp> ( incr seconds -- mongo-timestamp )
    mongo-timestamp boa ;

TUPLE: mongo-scoped-code code object ;

: <mongo-scoped-code> ( code object -- mongo-scoped-code )
    mongo-scoped-code boa ;

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

CONSTANT: T_EOO     0
CONSTANT: T_Double  HEX: 1
CONSTANT: T_String  HEX: 2
CONSTANT: T_Object  HEX: 3
CONSTANT: T_Array   HEX: 4
CONSTANT: T_Binary  HEX: 5
CONSTANT: T_Undefined  HEX: 6
CONSTANT: T_OID     HEX: 7
CONSTANT: T_Boolean HEX: 8
CONSTANT: T_Date    HEX: 9
CONSTANT: T_NULL    HEX: A
CONSTANT: T_Regexp  HEX: B
CONSTANT: T_DBRef   HEX: C
CONSTANT: T_Code    HEX: D
CONSTANT: T_Symbol  HEX: E
CONSTANT: T_ScopedCode HEX: F
CONSTANT: T_Integer HEX: 10
CONSTANT: T_Timestamp HEX: 11
CONSTANT: T_Integer64 HEX: 12
CONSTANT: T_MinKey  HEX: FF
CONSTANT: T_MaxKey  HEX: 7F

CONSTANT: T_Binary_Function     HEX: 1
CONSTANT: T_Binary_Bytes        HEX: 2
CONSTANT: T_Binary_UUID         HEX: 3
CONSTANT: T_Binary_MD5          HEX: 5
CONSTANT: T_Binary_Custom       HEX: 80

