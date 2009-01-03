USING: alien.c-types ;

IN: bson.constants

TUPLE: oid { a initial: 0 } { b initial: 0 } ;


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


