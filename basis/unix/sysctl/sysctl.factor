! Copyright (C) 2008 Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.strings alien.syntax
byte-arrays io.encodings.utf8 kernel libc locals sequences
specialized-arrays ;
IN: unix.sysctl

SPECIALIZED-ARRAY: int

LIBRARY: libc
FUNCTION: int sysctl ( int* name, uint namelen, void* oldp, size_t* oldlenp, void* newp, size_t newlen )
FUNCTION: int sysctlbyname ( c-string name, void* oldp, size_t* oldlenp, void* newp, size_t newlen )

: (sysctl-query) ( name namelen oldp oldlenp -- oldp )
    over [ f 0 sysctl io-error ] dip ;

: (sysctl-name-query) ( name oldp oldlenp -- oldp )
    over [ f 0 sysctlbyname io-error ] dip ;

:: sysctl-query ( seq n -- byte-array )
    seq int >c-array :> name
    n <byte-array> :> bytes
    n size_t <ref> :> oldlen
    name seq length bytes oldlen (sysctl-query) drop
    oldlen size_t deref bytes resize-byte-array ;

:: sysctl-name-query ( name n -- byte-array )
    n <byte-array> :> bytes
    n size_t <ref> :> oldlen
    name bytes oldlen (sysctl-name-query) drop
    oldlen size_t deref bytes resize-byte-array ;

: sysctl-query-string ( seq -- n )
    4096 sysctl-query utf8 alien>string ;

: sysctl-name-query-string ( str -- n )
    4096 sysctl-name-query utf8 alien>string ;

: sysctl-query-uint ( seq -- n )
    4 sysctl-query uint deref ;

: sysctl-name-query-uint ( str -- n )
    4 sysctl-name-query uint deref ;

: sysctl-query-ulonglong ( seq -- n )
    8 sysctl-query ulonglong deref ;

: sysctl-name-query-ulonglong ( str -- n )
    8 sysctl-name-query ulonglong deref ;
