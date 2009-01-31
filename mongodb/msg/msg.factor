USING: accessors alien.c-types alien.strings assocs bson.reader
bson.writer byte-arrays byte-vectors constructors fry io
io.encodings.binary io.encodings.utf8 io.streams.byte-array kernel
linked-assocs math namespaces sequences strings ;

IN: mongodb.msg

<PRIVATE

CONSTANT: OP_Reply   1 
CONSTANT: OP_Message 1000 
CONSTANT: OP_Update  2001 
CONSTANT: OP_Insert  2002 
CONSTANT: OP_Query   2004 
CONSTANT: OP_GetMore 2005 
CONSTANT: OP_Delete  2006 
CONSTANT: OP_KillCursors 2007 

PREDICATE: mdb-reply-op < integer OP_Reply = ;
PREDICATE: mdb-query-op < integer OP_Query = ;
PREDICATE: mdb-insert-op < integer OP_Insert = ;
PREDICATE: mdb-update-op < integer OP_Update = ;
PREDICATE: mdb-delete-op < integer OP_Delete = ;
PREDICATE: mdb-getmore-op < integer OP_GetMore = ;
PREDICATE: mdb-killcursors-op < integer OP_KillCursors = ;

PRIVATE>

TUPLE: mdb-msg
{ opcode integer } 
{ req-id integer initial: 0 }
{ resp-id integer initial: 0 }
{ length integer initial: 0 }     
{ flags integer initial: 0 } ;

TUPLE: mdb-insert-msg < mdb-msg
{ collection string }
{ objects sequence } ;

TUPLE: mdb-update-msg < mdb-msg
{ collection string }
{ upsert? integer initial: 1 }
{ selector assoc }
{ object assoc } ;

TUPLE: mdb-delete-msg < mdb-msg
{ collection string }
{ selector assoc } ;

TUPLE: mdb-getmore-msg < mdb-msg
{ collection string }
{ return# integer initial: 0 }
{ cursor integer initial: 0 } ;

TUPLE: mdb-killcursors-msg < mdb-msg
{ cursors# integer initial: 0 }
{ cursors sequence } ;

TUPLE: mdb-query-msg < mdb-msg
{ collection string }
{ skip# integer initial: 0 }
{ return# integer initial: 0 }
{ query assoc }
{ returnfields assoc }
{ orderby sequence } ;

TUPLE: mdb-reply-msg < mdb-msg
{ cursor integer initial: 0 }
{ start# integer initial: 0 }
{ returned# integer initial: 0 }
{ objects sequence } ;


CONSTRUCTOR: mdb-getmore-msg ( collection return# -- mdb-getmore-msg )
    OP_GetMore >>opcode ; inline

CONSTRUCTOR: mdb-delete-msg ( collection selector -- mdb-delete-msg )
    OP_Delete >>opcode ; inline

CONSTRUCTOR: mdb-query-msg ( collection query -- mdb-query-msg )
    OP_Query >>opcode ; inline

GENERIC: <mdb-killcursors-msg> ( object -- mdb-killcursors-msg )

M: sequence <mdb-killcursors-msg> ( sequences -- mdb-killcursors-msg )
    [ mdb-killcursors-msg new ] dip
    [ length >>cursors# ] keep
    >>cursors OP_KillCursors >>opcode ; inline

M: integer <mdb-killcursors-msg> ( integer -- mdb-killcursors-msg )
    V{ } clone [ push ] keep <mdb-killcursors-msg> ;

GENERIC# <mdb-insert-msg> 1 ( collection objects -- mdb-insert-msg )

M: linked-assoc <mdb-insert-msg> ( collection linked-assoc -- mdb-insert-msg )
    [ mdb-insert-msg new ] 2dip
    [ >>collection ] dip
    V{ } clone tuck push
    >>objects OP_Insert >>opcode ;

M: sequence <mdb-insert-msg> ( collection sequence -- mdb-insert-msg )
    [ mdb-insert-msg new ] 2dip
    [ >>collection ] dip
    >>objects OP_Insert >>opcode ;

CONSTRUCTOR: mdb-update-msg ( collection object -- mdb-update-msg )
    dup object>> [ "_id" ] dip at "_id" H{ } clone [ set-at ] keep >>selector 
    OP_Update >>opcode ;
    
CONSTRUCTOR: mdb-reply-msg ( -- mdb-reply-msg ) ; inline

GENERIC: write-message ( message -- )

<PRIVATE

CONSTANT: MSG-HEADER-SIZE 16

SYMBOL: msg-bytes-read 

: bytes-read> ( -- integer )
    msg-bytes-read get ; inline

: >bytes-read ( integer -- )
    msg-bytes-read set ; inline

: change-bytes-read ( integer -- )
    bytes-read> [ 0 ] unless* + >bytes-read ; inline

: write-byte ( byte -- ) <char> write ; inline
: write-int32 ( int -- ) <int> write ; inline
: write-double ( real -- ) <double> write ; inline
: write-cstring ( string -- ) utf8 string>alien write ; inline
: write-longlong ( object -- ) <longlong> write ; inline

: read-int32 ( -- int32 ) 4 [ read *int ] [ change-bytes-read ] bi ; inline
: read-longlong ( -- longlong ) 8 [ read *longlong ] [ change-bytes-read ] bi ; inline
: read-byte-raw ( -- byte-raw ) 1 [ read ] [ change-bytes-read ] bi ; inline
: read-byte ( -- byte ) read-byte-raw first ; inline

: (read-cstring) ( acc -- )
    [ read-byte ] dip ! b acc
    2dup push             ! b acc
    [ 0 = ] dip      ! bool acc
    '[ _ (read-cstring) ] unless ; inline recursive

: read-cstring ( -- string )
    BV{ } clone
    [ (read-cstring) ] keep
    >byte-array utf8 alien>string ; inline

GENERIC: (read-message) ( message opcode -- message )

: copy-header ( message msg-stub -- message )
    [ length>> ] keep [ >>length ] dip
    [ req-id>> ] keep [ >>req-id ] dip
    [ resp-id>> ] keep [ >>resp-id ] dip
    [ opcode>> ] keep [ >>opcode ] dip
    flags>> >>flags ;

M: mdb-query-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-query-msg new ] dip copy-header
    read-cstring >>collection
    read-int32 >>skip#
    read-int32 >>return#
    H{ } stream>assoc change-bytes-read >>query 
    dup length>> bytes-read> >
    [ H{ } stream>assoc change-bytes-read >>returnfields 
      dup length>> bytes-read> >
      [ H{ } stream>assoc drop >>orderby ] when
    ] when ;

M: mdb-insert-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-insert-msg new ] dip copy-header
    read-cstring >>collection
    V{ } clone >>objects
    [ '[ _ length>> bytes-read> > ] ] keep tuck
    '[ H{ } stream>assoc change-bytes-read _ objects>> push ]
    [ ] while ;

M: mdb-delete-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-delete-msg new ] dip copy-header
    read-cstring >>collection
    H{ } stream>assoc change-bytes-read >>selector ;

M: mdb-getmore-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-getmore-msg new ] dip copy-header
    read-cstring >>collection
    read-int32 >>return#
    read-longlong >>cursor ;

M: mdb-killcursors-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-killcursors-msg new ] dip copy-header
    read-int32 >>cursors#
    V{ } clone >>cursors
    [ [ cursors#>> ] keep 
      '[ read-longlong _ cursors>> push ] times ] keep ;

M: mdb-update-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-update-msg new ] dip copy-header
    read-cstring >>collection
    read-int32 >>upsert?
    H{ } stream>assoc change-bytes-read >>selector
    H{ } stream>assoc change-bytes-read >>object ;

M: mdb-reply-op (read-message) ( msg-stub opcode -- message )
    drop
    [ <mdb-reply-msg> ] dip copy-header
    read-longlong >>cursor
    read-int32 >>start#
    read-int32 [ >>returned# ] keep
    [ H{ } stream>assoc drop ] accumulator [ times ] dip >>objects ;    

: read-header ( message -- message )
    read-int32 >>length
    read-int32 >>req-id
    read-int32 >>resp-id
    read-int32 >>opcode
    read-int32 >>flags ; inline

: write-header ( message length -- )
    MSG-HEADER-SIZE + write-int32
    [ req-id>> write-int32 ] keep
    [ resp-id>> write-int32 ] keep 
    opcode>> write-int32 ; inline

PRIVATE>

: read-message ( -- message )
    mdb-msg new
    0 >bytes-read
    read-header
    [ ] [ opcode>> ] bi (read-message) ;

<PRIVATE

: (write-message) ( message quot -- )
     [ binary ] dip with-byte-writer 
     [ length write-header ] keep 
     write flush ; inline

PRIVATE>

M: mdb-query-msg write-message ( message -- )
     dup
     '[ _ 
        [ flags>> write-int32 ] keep 
        [ collection>> write-cstring ] keep
        [ skip#>> write-int32 ] keep
        [ return#>> write-int32 ] keep
        query>> assoc>array write
     ] (write-message) ;
 
M: mdb-insert-msg write-message ( message -- )
    dup
    '[ _
       [ flags>> write-int32 ] keep
       [ collection>> write-cstring ] keep
       objects>> [ assoc>array write ] each
    ] (write-message) ;

M: mdb-update-msg write-message ( message -- )
    dup
    '[ _
       [ flags>> write-int32 ] keep
       [ collection>> write-cstring ] keep
       [ upsert?>> write-int32 ] keep
       [ selector>> assoc>array write ] keep
       object>> assoc>array write
    ] (write-message) ;

M: mdb-delete-msg write-message ( message -- )
    dup
    '[ _
       [ flags>> write-int32 ] keep
       [ collection>> write-cstring ] keep
       0 write-int32
       selector>> assoc>array write
    ] (write-message) ;

M: mdb-getmore-msg write-message ( message -- )
    dup
    '[ _
       [ flags>> write-int32 ] keep
       [ collection>> write-cstring ] keep
       [ return#>> write-int32 ] keep
       cursor>> write-longlong
    ] (write-message) ;

M: mdb-killcursors-msg write-message ( message -- )
    dup
    '[ _
       [ flags>> write-int32 ] keep
       [ cursors#>> write-int32 ] keep
       cursors>> [ write-longlong ] each
    ] (write-message) ;