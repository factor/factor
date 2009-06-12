USING: kernel alien combinators alien.syntax
       alien.c-types
       alien.libraries ;
IN: tokyo.alient.tcutil

C-ENUM:
    TCDBTHASH
    TCDBTBTREE
    TCDBTFIXED
    TCDBTTABLE ;

! FIXME: time_t varies from system to system, right?
TYPEDEF: longlong time_t

TYPEDEF: void* TCLIST*

FUNCTION: TCLIST* tclistnew ( ) ;
FUNCTION: TCLIST* tclistnew2 ( int anum ) ;
FUNCTION: void tclistdel ( TCLIST* list ) ;
FUNCTION: int tclistnum ( TCLIST* list ) ;
FUNCTION: void* tclistval ( TCLIST* list, int index, int* sp ) ;
FUNCTION: char* tclistval2 ( TCLIST* list, int index ) ;
FUNCTION: void tclistpush ( TCLIST* list, void* ptr, int size ) ;
FUNCTION: void tclistpush2 ( TCLIST* list, char* str ) ;
