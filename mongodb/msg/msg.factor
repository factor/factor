USING: io io.encodings.utf8 io.encodings.binary alien.c-types alien.strings math
bson.writer sequences kernel accessors io.streams.byte-array fry generalizations
combinators bson.reader sequences tools.walker assocs strings linked-assocs ;

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


: <mdb-query-msg> ( collection assoc -- mdb-query-msg )
     [ mdb-query-msg new ] 2dip
     [ >>collection ] dip
     >>query OP_Query >>opcode ; inline

: <mdb-query-one-msg> ( collection assoc -- mdb-query-msg )
    <mdb-query-msg> 1 >>return# ; inline

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


: <mdb-reply-msg> ( -- mdb-reply-msg )
    mdb-reply-msg new ; inline

GENERIC: write-message ( message -- )

<PRIVATE

CONSTANT: MSG-HEADER-SIZE 16

: write-byte ( byte -- ) <char> write ; inline
: write-int32 ( int -- ) <int> write ; inline
: write-double ( real -- ) <double> write ; inline
: write-cstring ( string -- ) utf8 string>alien write ; inline
: write-longlong ( object -- ) <longlong> write ; inline

: read-int32 ( -- int32 ) 4 read *int ; inline
: read-longlong ( -- longlong ) 8 read *longlong ; inline
: read-byte-raw ( -- byte-raw ) 1 read ; inline
: read-byte ( -- byte ) read-byte-raw *char ; inline

: (read-cstring) ( acc -- acc )
    read-byte-raw dup
    B{ 0 } =
    [ append ]
    [ append (read-cstring) ] if ; recursive inline

: read-cstring ( -- string )
    B{ } clone
    (read-cstring) utf8 alien>string ; inline

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
    H{ } stream>assoc >>query ;

M: mdb-insert-op (read-message) ( msg-stub opcode -- message )
    drop
    [ mdb-insert-msg new ] dip copy-header
    read-cstring >>collection
    H{ } stream>assoc >>objects ;

M: mdb-reply-op (read-message) ( msg-stub opcode -- message )
    drop
    [ <mdb-reply-msg> ] dip copy-header
    read-longlong >>cursor
    read-int32 >>start#
    read-int32 [ >>returned# ] keep
    [ H{ } stream>assoc ] accumulator [ times ] dip >>objects ;    

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
    read-header
    [ ] [ opcode>> ] bi (read-message) ;

<PRIVATE

: (write-message) ( message quot -- )
     [ binary ] dip with-byte-writer dup
     [ length write-header ] dip 
     write flush ; inline

PRIVATE>

M: mdb-query-msg write-message ( message -- )
     dup
     '[ _ 
        [ 4 write-int32 ] dip 
        [ collection>> write-cstring ] keep
        [ skip#>> write-int32 ] keep
        [ return#>> write-int32 ] keep
        query>> assoc>array write
     ] (write-message) ;
 
M: mdb-insert-msg write-message ( message -- )
     dup
     '[ _
        [ 0 write-int32 ] dip
        [ collection>> write-cstring ] keep
        objects>> [ assoc>array write ] each
     ] (write-message) ;

