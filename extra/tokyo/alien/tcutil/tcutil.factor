! Copyright (C) 2009 Bruno Deferrari
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: tokyo.alien.tcutil

<< "tokyocabinet" {
    { [ os macosx? ] [ "libtokyocabinet.dylib" ] }
    { [ os unix? ] [ "libtokyocabinet.so" ] }
    { [ os windows? ] [ "tokyocabinet.dll" ] }
} cond cdecl add-library >>

LIBRARY: tokyocabinet

CONSTANT: TCDBTHASH 0
CONSTANT: TCDBTBTREE 1
CONSTANT: TCDBTFIXED 2
CONSTANT: TCDBTTABLE 3

! FIXME: on windows 64bits this isn't correct, because long is 32bits there, and time_t is int64
TYPEDEF: long tokyo_time_t

C-TYPE: TCLIST

FUNCTION: TCLIST* tclistnew ( )
FUNCTION: TCLIST* tclistnew2 ( int anum )
FUNCTION: void tclistdel ( TCLIST* list )
FUNCTION: int tclistnum ( TCLIST* list )
FUNCTION: void* tclistval ( TCLIST* list, int index, int* sp )
FUNCTION: c-string tclistval2 ( TCLIST* list, int index )
FUNCTION: void tclistpush ( TCLIST* list, void* ptr, int size )
FUNCTION: void tclistpush2 ( TCLIST* list, c-string str )
FUNCTION: void tcfree ( void* ptr )

TYPEDEF: void* TCCMP
TYPEDEF: void* TCCODEC
TYPEDEF: void* TCPDPROC
TYPEDEF: void* TCITER
