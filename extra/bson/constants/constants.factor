! Copyright (C) 2010 Sascha Matzke.
! See https://factorcode.org/license.txt for BSD license.
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
    8 random-bits 16 shift 0xFF0000 mask
    16 random-bits 0xFFFF mask
    bitor >>b ;

TUPLE: dbref ref id db ;

TUPLE: mongo-timestamp incr seconds ;

: <mongo-timestamp> ( incr seconds -- mongo-timestamp )
    mongo-timestamp boa ;

TUPLE: mongo-scoped-code code object ;

: <mongo-scoped-code> ( code object -- mongo-scoped-code )
    mongo-scoped-code boa ;

CONSTRUCTOR: <dbref> dbref ( ref id -- dbref ) ;

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
    [ "$ref" of ] [ "$id" of ] [ "$db" of ] tri
    dbref boa ; inline

: dbref-assoc? ( assoc -- ? )
    { [ "$ref" swap key? ] [ "$id" swap key? ] } 1&& ; inline

TUPLE: mdbregexp { regexp string } { options string } ;

: <mdbregexp> ( string -- mdbregexp )
    [ mdbregexp new ] dip >>regexp ;


CONSTANT: MDB_OID_FIELD "_id"
CONSTANT: MDB_META_FIELD "_mfd"

CONSTANT: T_EOO     0
CONSTANT: T_Double  0x1
CONSTANT: T_String  0x2
CONSTANT: T_Object  0x3
CONSTANT: T_Array   0x4
CONSTANT: T_Binary  0x5
CONSTANT: T_Undefined  0x6
CONSTANT: T_OID     0x7
CONSTANT: T_Boolean 0x8
CONSTANT: T_Date    0x9
CONSTANT: T_NULL    0xA
CONSTANT: T_Regexp  0xB
CONSTANT: T_DBRef   0xC
CONSTANT: T_Code    0xD
CONSTANT: T_Symbol  0xE
CONSTANT: T_ScopedCode 0xF
CONSTANT: T_Integer 0x10
CONSTANT: T_Timestamp 0x11
CONSTANT: T_Integer64 0x12
CONSTANT: T_MinKey  0xFF
CONSTANT: T_MaxKey  0x7F

CONSTANT: T_Binary_Default                  0x0
CONSTANT: T_Binary_Function                 0x1
CONSTANT: T_Binary_Bytes_Deprecated         0x2
CONSTANT: T_Binary_UUID                     0x3
CONSTANT: T_Binary_MD5                      0x5
CONSTANT: T_Binary_Custom                   0x80
