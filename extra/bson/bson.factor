! Copyright (C) 2010 Sascha Matzke.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors alien.accessors arrays assocs bson.constants
byte-arrays byte-vectors calendar combinators
combinators.short-circuit dlists endian hashtables io
io.encodings io.encodings.binary io.encodings.utf8 io.files
io.streams.byte-array kernel linked-assocs math math.parser
namespaces quotations sequences sequences.extras serialize
strings typed vectors words ;

IN: bson

DEFER: stream>assoc

ERROR: unknown-bson-type type msg ;

<PRIVATE

SYMBOL: state

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
    ] 1guard ;

: path>bson-sequence ( path -- assoc )
    binary [
        [ H{ } stream>assoc ] loop>array
    ] with-file-reader ;

<PRIVATE

CONSTANT: INT32-SIZE 4
CONSTANT: INT64-SIZE 8

TYPED: get-output ( -- stream: byte-vector )
    output-stream get ; inline

TYPED: with-length ( quot -- bytes-written: integer start-index: integer )
    [ get-output [ length ] [ ] bi ] dip
    call length swap [ - ] keep ; inline

: (with-length-prefix) ( quot: ( .. -- .. ) length-quot: ( bytes-written -- length ) -- )
    [ [ B{ 0 0 0 0 } write ] prepose with-length ] dip swap
    [ call( written -- length ) get-output underlying>> ] dip set-alien-unsigned-4 ; inline

: with-length-prefix ( quot: ( .. -- .. ) -- )
    [ ] (with-length-prefix) ; inline

: with-length-prefix-excl ( quot: ( .. -- .. ) -- )
    [ 4 - ] (with-length-prefix) ; inline

: write-le ( x n -- )
    <iota> [ nth-byte write1 ] with each ; inline

TYPED: write-int32 ( int: integer -- )
    INT32-SIZE write-le ; inline

TYPED: write-double ( real: float -- )
    double>bits INT64-SIZE write-le ; inline

TYPED: write-utf8-string ( string: string -- )
    get-output utf8 encode-string ; inline

TYPED: write-cstring ( string: string -- )
    write-utf8-string 0 write1 ; inline

: write-longlong ( object -- )
    INT64-SIZE write-le ; inline

: write-eoo ( -- ) T_EOO write1 ; inline

TYPED: write-header ( name: string object type: integer -- object )
    write1 [ write-cstring ] dip ; inline

DEFER: write-pair

TYPED: write-byte-array ( binary: byte-array -- )
    [ length write-int32 ]
    [ T_Binary_Default write1 write ] bi ; inline

TYPED: write-mdbregexp ( regexp: mdbregexp -- )
    [ regexp>> write-cstring ]
    [ options>> write-cstring ] bi ; inline

TYPED: write-sequence ( array: sequence -- )
    '[
        _ [ number>string swap write-pair ] each-index
        write-eoo
    ] with-length-prefix ; inline recursive

TYPED: write-oid ( oid: oid -- )
    [ a>> write-longlong ] [ b>> write-int32 ] bi ; inline

: write-oid-field ( assoc -- )
    [ MDB_OID_FIELD dup ] dip at
    [ dup oid? [ T_OID write-header write-oid ] [ write-pair ] if ]
    [ drop ] if* ; inline

: skip-field? ( name value -- name value boolean )
    over { [ MDB_OID_FIELD = ] [ MDB_META_FIELD = ] } 1|| ; inline

UNION: hashtables hashtable linked-assoc ;

TYPED: write-assoc ( assoc: hashtables -- )
    '[ _ [ write-oid-field ] [
            [ skip-field? [ 2drop ] [ write-pair ] if ] assoc-each
        ] bi write-eoo
    ] with-length-prefix ; inline recursive

UNION: code word quotation ;

TYPED: (serialize-code) ( code: code -- )
  object>bytes
  [ length write-int32 ]
  [ T_Binary_Custom write1 write ] bi ; inline

: write-string-length ( string -- )
    [ length>> 1 + ] [ aux>> length ] bi + write-int32 ; inline

TYPED: write-string ( string: string -- )
    dup write-string-length write-cstring ; inline

TYPED: write-boolean ( bool: boolean -- )
    [ 1 write1 ] [ 0 write1 ] if ; inline

TYPED: write-pair ( name: string obj -- )
    {
        {
            [ dup { [ hashtable? ] [ linked-assoc? ] } 1|| ]
            [ T_Object write-header write-assoc ]
        } {
            [ dup { [ array? ] [ vector? ] [ dlist? ] } 1|| ]
            [ T_Array write-header write-sequence ]
        } {
            [ dup byte-array? ]
            [ T_Binary write-header write-byte-array ]
        } {
            [ dup string? ]
            [ T_String write-header write-string ]
        } {
            [ dup oid? ]
            [ T_OID write-header write-oid ]
        } {
            [ dup integer? ]
            [ T_Integer write-header write-int32 ]
        } {
            [ dup boolean? ]
            [ T_Boolean write-header write-boolean ]
        } {
            [ dup real? ]
            [ T_Double write-header >float write-double ]
        } {
            [ dup timestamp? ]
            [ T_Date write-header timestamp>millis write-longlong ]
        } {
            [ dup mdbregexp? ]
            [ T_Regexp write-header write-mdbregexp ]
        } {
            [ dup quotation? ]
            [ T_Binary write-header (serialize-code) ]
        } {
            [ dup word? ]
            [ T_Binary write-header (serialize-code) ]
        } {
            [ dup dbref? ]
            [ T_Object write-header dbref>assoc write-assoc ]
        } {
            [ dup f = ]
            [ T_NULL write-header drop ]
        }
    } cond ;

PRIVATE>

TYPED: assoc>bv ( assoc: hashtables -- byte-vector: byte-vector )
    [ BV{ } clone dup ] dip '[ _ write-assoc ] with-output-stream* ; inline

TYPED: assoc>stream ( assoc: hashtables -- )
    write-assoc ; inline

TYPED: mdb-special-value? ( value -- ?: boolean )
    {
        [ timestamp? ]
        [ quotation? ]
        [ mdbregexp? ]
        [ oid? ]
        [ byte-array? ]
    } 1|| ; inline
