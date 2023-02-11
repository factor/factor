USING: accessors assocs bson bson.private byte-arrays
byte-vectors combinators formatting endian fry io
io.encodings.private io.encodings.binary io.encodings.string
io.encodings.utf8 io.encodings.utf8.private io.files kernel
locals math mongodb.msg namespaces sequences uuid ;

FROM: mongodb.connection => connection-buffer ;
FROM: alien => byte-length ;

IN: mongodb.operations

M: byte-vector byte-length length ;

<PRIVATE

PREDICATE: mdb-reply-op < integer OP_Reply = ;
PREDICATE: mdb-query-op < integer OP_Query = ;
PREDICATE: mdb-insert-op < integer OP_Insert = ;
PREDICATE: mdb-update-op < integer OP_Update = ;
PREDICATE: mdb-delete-op < integer OP_Delete = ;
PREDICATE: mdb-getmore-op < integer OP_GetMore = ;
PREDICATE: mdb-killcursors-op < integer OP_KillCursors = ;

CONSTANT: MSG-HEADER-SIZE 16

SYMBOL: msg-bytes-read

: bytes-read> ( -- integer )
    msg-bytes-read get ; inline

: >bytes-read ( integer -- )
    msg-bytes-read set ; inline

: change-bytes-read ( integer -- )
    bytes-read> [ 0 ] unless* + >bytes-read ; inline

: read-int32 ( -- int32 ) 4 [ read le> ] [ change-bytes-read ] bi ; inline
: read-longlong ( -- longlong ) 8 [ read le> ] [ change-bytes-read ] bi ; inline
: read-byte-raw ( -- byte-raw ) 1 [ read le> ] [ change-bytes-read ] bi ; inline
: read-byte ( -- byte ) read-byte-raw first ; inline

: copy-header ( message msg-stub -- message )
    {
        [ length>> >>length ]
        [ req-id>> >>req-id ]
        [ resp-id>> >>resp-id ]
        [ opcode>> >>opcode ]
        [ flags>> >>flags ]
    } cleave ; inline

: reply-read-message ( msg-stub -- message )
    [ <mdb-reply-msg> ] dip copy-header
    read-longlong >>cursor
    read-int32 >>start#
    read-int32 [ >>returned# ] keep
    [ H{ } clone stream>assoc ] collector [ times ] dip >>objects ;

: (read-message) ( message opcode -- message )
    OP_Reply =
    [ reply-read-message ]
    [ "unknown message type" throw ] if ; inline

: read-header ( message -- message )
    read-int32 >>length
    read-int32 >>req-id
    read-int32 >>resp-id
    read-int32 >>opcode
    read-int32 >>flags ; inline

: write-header ( message -- )
    [ req-id>> write-int32 ]
    [ resp-id>> write-int32 ]
    [ opcode>> write-int32 ] tri ; inline

PRIVATE>

: read-message ( -- message )
    [
        mdb-msg new 0 >bytes-read read-header
        [ ] [ opcode>> ] bi (read-message)
    ] with-scope ;

<PRIVATE

: (write-message) ( message quot -- )
    [ connection-buffer dup ] 2dip
    '[
        [ _ [ write-header ] _ bi ] with-length-prefix
    ] with-output-stream* write flush ; inline

:: build-query-object ( query -- selector )
    H{ } clone :> selector
    query {
        [ orderby>> [ "$orderby" selector set-at ] when* ]
        [ explain>> [ "$explain" selector set-at ] when* ]
        [ hint>> [ "$hint" selector set-at ] when* ]
        [ query>> "query" selector set-at ]
    } cleave selector ; inline

: write-query-message ( message -- )
    [
        {
            [ flags>> write-int32 ]
            [ collection>> write-cstring ]
            [ skip#>> write-int32 ]
            [ return#>> write-int32 ]
            [ build-query-object assoc>stream ]
            [ returnfields>> [ assoc>stream ] when* ]
        } cleave
    ] (write-message) ; inline

: write-insert-message ( message -- )
    [
        [ flags>> write-int32 ]
        [ collection>> write-cstring ]
        [ objects>> [ assoc>stream ] each ] tri
    ] (write-message) ; inline

: write-update-message ( message -- )
    [
        {
            [ flags>> write-int32 ]
            [ collection>> write-cstring ]
            [ update-flags>> write-int32 ]
            [ selector>> assoc>stream ]
            [ object>> assoc>stream ]
        } cleave
    ] (write-message) ; inline

: write-delete-message ( message -- )
    [
        {
            [ flags>> write-int32 ]
            [ collection>> write-cstring ]
            [ delete-flags>> write-int32 ]
            [ selector>> assoc>stream ]
        } cleave
    ] (write-message) ; inline

: write-getmore-message ( message -- )
    [
        {
           [ flags>> write-int32 ]
           [ collection>> write-cstring ]
           [ return#>> write-int32 ]
           [ cursor>> write-longlong ]
        } cleave
    ] (write-message) ; inline

: write-killcursors-message ( message -- )
    [
        [ flags>> write-int32 ]
        [ cursors#>> write-int32 ]
        [ cursors>> [ write-longlong ] each ] tri
    ] (write-message) ; inline

PRIVATE>

: write-message ( message -- )
    {
        { [ dup mdb-query-msg? ] [ write-query-message ] }
        { [ dup mdb-insert-msg? ] [ write-insert-message ] }
        { [ dup mdb-update-msg? ] [ write-update-message ] }
        { [ dup mdb-delete-msg? ] [ write-delete-message ] }
        { [ dup mdb-getmore-msg? ] [ write-getmore-message ] }
        { [ dup mdb-killcursors-msg? ] [ write-killcursors-message ] }
    } cond ;
