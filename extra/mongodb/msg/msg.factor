USING: accessors assocs hashtables constructors kernel linked-assocs math
sequences strings ;

IN: mongodb.msg

CONSTANT: OP_Reply   1 
CONSTANT: OP_Message 1000 
CONSTANT: OP_Update  2001 
CONSTANT: OP_Insert  2002 
CONSTANT: OP_Query   2004 
CONSTANT: OP_GetMore 2005 
CONSTANT: OP_Delete  2006 
CONSTANT: OP_KillCursors 2007

CONSTANT: ResultFlag_CursorNotFound  1 ! /* returned, with zero results, when getMore is called but the cursor id is not valid at the server. */
CONSTANT: ResultFlag_ErrSet  2 ! /* { $err : ... } is being returned */
CONSTANT: ResultFlag_ShardConfigStale 4 !  /* have to update config from the server,  usually $err is also set */
            
TUPLE: mdb-msg
{ opcode integer } 
{ req-id integer initial: 0 }
{ resp-id integer initial: 0 }
{ length integer initial: 0 }     
{ flags integer initial: 0 } ;

TUPLE: mdb-query-msg < mdb-msg
{ collection string }
{ skip# integer initial: 0 }
{ return# integer initial: 0 }
{ query assoc }
{ returnfields assoc }
{ orderby sequence }
explain hint ;

TUPLE: mdb-insert-msg < mdb-msg
{ collection string }
{ objects sequence } ;

TUPLE: mdb-update-msg < mdb-msg
{ collection string }
{ upsert? integer initial: 0 }
{ selector assoc }
{ object assoc } ;

TUPLE: mdb-delete-msg < mdb-msg
{ collection string }
{ selector assoc } ;

TUPLE: mdb-getmore-msg < mdb-msg
{ collection string }
{ return# integer initial: 0 }
{ cursor integer initial: 0 }
{ query mdb-query-msg } ;

TUPLE: mdb-killcursors-msg < mdb-msg
{ cursors# integer initial: 0 }
{ cursors sequence } ;

TUPLE: mdb-reply-msg < mdb-msg
{ collection string }
{ cursor integer initial: 0 }
{ start# integer initial: 0 }
{ requested# integer initial: 0 }
{ returned# integer initial: 0 }
{ objects sequence } ;


CONSTRUCTOR: mdb-getmore-msg ( collection return# cursor -- mdb-getmore-msg )
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

GENERIC: <mdb-insert-msg> ( collection objects -- mdb-insert-msg )

M: sequence <mdb-insert-msg> ( collection sequence -- mdb-insert-msg )
    [ mdb-insert-msg new ] 2dip
    [ >>collection ] dip
    >>objects OP_Insert >>opcode ;

M: assoc <mdb-insert-msg> ( collection assoc -- mdb-insert-msg )
    [ mdb-insert-msg new ] 2dip
    [ >>collection ] dip
    V{ } clone tuck push
    >>objects OP_Insert >>opcode ;


CONSTRUCTOR: mdb-update-msg ( collection selector object -- mdb-update-msg )
    OP_Update >>opcode ; inline
    
CONSTRUCTOR: mdb-reply-msg ( -- mdb-reply-msg ) ; inline

