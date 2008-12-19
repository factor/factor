USING: alien.c-types ;

IN: mongodb.bson.constants


: T_EOO ( -- type ) 0 ; inline
: T_Double ( -- type ) 1 ; inline
: T_Integer ( -- type ) 16 ; inline
: T_Boolean ( -- type ) 8 ; inline
: T_String ( -- type ) 2 ; inline
: T_Object ( -- type ) 3 ; inline
: T_Array ( -- type ) 4 ; inline
: T_Binary ( -- type ) 5 ; inline
: T_Undefined ( -- type ) 6 ; inline
: T_OID ( -- type ) 7 ; inline
: T_Date ( -- type ) 9 ; inline
: T_NULL ( -- type ) 10 ; inline
: T_Regexp ( -- type ) 11 ; inline
: T_DBRef ( -- type ) 12 ; inline
: T_Code ( -- type ) 13 ; inline
: T_ScopedCode ( -- type ) 17 ; inline
: T_Symbol ( -- type ) 14 ; inline
: T_JSTypeMax ( -- type ) 16 ; inline
: T_MaxKey ( -- type ) 127 ; inline

: T_Binary_Bytes ( -- subtype ) 2 ; inline
: T_Binary_Function ( -- subtype ) 1 ; inline 

: S_Name ( -- name ) "__t_name" ; inline
: S_Vocab ( -- name ) "__t_vocab" ; inline

! todo Move to mongo vocab 

: OP_Reply ( -- const )
    1 <int> ; inline

: OP_Message ( -- const )
    1000 <int> ; inline

: OP_Update ( -- const )
    2001 <int> ; inline

: OP_Insert ( -- const )
    2002 <int> ; inline

: OP_Query ( -- const )
    2004 <int> ; inline

: OP_GetMore ( -- const )
    2005 <int> ; inline

: OP_Delete ( -- const )
    2006 <int> ; inline

: OP_KillCursors ( -- const )
    2007 <int> ; inline
    