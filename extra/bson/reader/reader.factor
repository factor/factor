! Copyright (C) 2010 Sascha Matzke.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bson.constants byte-arrays calendar
combinators combinators.short-circuit io io.binary io.encodings
io.encodings.binary io.encodings.utf8 io.files
io.streams.byte-array kernel locals math namespaces sequences
sequences.extras serialize strings typed vectors ;
IN: bson.reader

SYMBOL: state

DEFER: stream>assoc

ERROR: unknown-bson-type type msg ;

<PRIVATE

DEFER: read-elements

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
    input-stream get utf8 <decoder>
    "\0" swap stream-read-until drop ; inline

: read-sized-string ( length -- string )
    read binary [ read-cstring ] with-byte-reader ; inline

: read-timestamp ( -- timestamp )
    8 read [ 4 head signed-le> ] [ 4 tail signed-le> ] bi <mongo-timestamp> ;

: object-result ( quot -- object )
    [
        state get clone
        [ clear-assoc ] [ ] [ ] tri state
    ] dip with-variable ; inline

: bson-object-data-read ( -- ? )
    read-int32 [ f ] [ drop read-elements t ] if-zero ; inline recursive

: bson-binary-read ( -- binary )
   read-int32 read-byte
   {
        { T_Binary_Default [ read ] }
        { T_Binary_Bytes_Deprecated [ drop read-int32 read ] }
        { T_Binary_Custom [ read bytes>object ] }
        { T_Binary_Function [ read-sized-string ] }
        { T_Binary_MD5 [ read >string ] }
        { T_Binary_UUID [ read >string ] }
        [ "unknown binary sub-type" unknown-bson-type ]
   } case ; inline

TYPED: bson-regexp-read ( -- mdbregexp: mdbregexp )
   mdbregexp new
   read-cstring >>regexp read-cstring >>options ; inline

TYPED: bson-oid-read ( -- oid: oid )
    read-longlong read-int32 oid boa ; inline

: check-object ( assoc -- object )
    dup dbref-assoc? [ assoc>dbref ] when ; inline

TYPED: element-data-read ( type: integer -- object )
    {
        { T_OID         [ bson-oid-read ] }
        { T_String      [ read-int32 read-sized-string ] }
        { T_Integer     [ read-int32 ] }
        { T_Integer64   [ read-longlong ] }
        { T_Binary      [ bson-binary-read ] }
        { T_Object      [ [ bson-object-data-read drop ] object-result check-object ] }
        { T_Array       [ [ bson-object-data-read drop ] object-result values ] }
        { T_Double      [ read-double ] }
        { T_Boolean     [ read-byte 1 = ] }
        { T_Date        [ read-longlong millis>timestamp ] }
        { T_Regexp      [ bson-regexp-read ] }
        { T_Timestamp   [ read-timestamp ] }
        { T_Code        [ read-int32 read-sized-string ] }
        { T_ScopedCode  [ read-int32 drop read-cstring H{ } clone stream>assoc <mongo-scoped-code> ] }
        { T_NULL        [ f ] }
        [ "type unknown" unknown-bson-type ]
    } case ; inline recursive

TYPED: (read-object) ( type: integer name: string -- )
    [ element-data-read ] dip state get set-at ; inline recursive

TYPED: (element-read) ( type: integer -- cont?: boolean )
    dup T_EOO >
    [ read-cstring (read-object) t ]
    [ drop f ] if ; inline recursive

: read-elements ( -- )
    read-byte (element-read)
    [ read-elements ] when ; inline recursive

PRIVATE>

: stream>assoc ( exemplar -- assoc/f )
    clone [
        state [ bson-object-data-read ] with-variable
    ] keep swap [ drop f ] unless ;

: path>bson-sequence ( path -- assoc )
    binary [
        [ H{ } stream>assoc ] loop>array
    ] with-file-reader ;
