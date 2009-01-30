! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings alien.syntax
byte-arrays kernel namespaces sequences unix
system-info.backend system io.encodings.utf8 ;
IN: system-info.macosx

! See /usr/include/sys/sysctl.h for constants

LIBRARY: libc
FUNCTION: int sysctl ( int* name, uint namelen, void* oldp, size_t* oldlenp, void* newp, size_t newlen ) ;

: make-int-array ( seq -- byte-array )
    [ <int> ] map concat ;

: (sysctl-query) ( name namelen oldp oldlenp -- oldp )
    over [ f 0 sysctl io-error ] dip ;

: sysctl-query ( seq n -- byte-array )
    [ [ make-int-array ] [ length ] bi ] dip
    [ <byte-array> ] [ <uint> ] bi (sysctl-query) ;

: sysctl-query-string ( seq -- n )
    4096 sysctl-query utf8 alien>string ;

: sysctl-query-uint ( seq -- n )
    4 sysctl-query *uint ;

: sysctl-query-ulonglong ( seq -- n )
    8 sysctl-query *ulonglong ;

: machine ( -- str ) { 6 1 } sysctl-query-string ;
: model ( -- str ) { 6 2 } sysctl-query-string ;
M: macosx cpus ( -- n ) { 6 3 } sysctl-query-uint ;
: byte-order ( -- n ) { 6 4 } sysctl-query-uint ;
M: macosx physical-mem ( -- n ) { 6 5 } sysctl-query-uint ;
: user-mem ( -- n ) { 6 6 } sysctl-query-uint ;
: page-size ( -- n ) { 6 7 } sysctl-query-uint ;
: disknames ( -- n ) { 6 8 } 8 sysctl-query ;
: diskstats ( -- n ) { 6 9 } 8 sysctl-query ;
: epoch ( -- n ) { 6 10 } sysctl-query-uint ;
: floating-point ( -- n ) { 6 11 } sysctl-query-uint ;
: machine-arch ( -- n ) { 6 12 } sysctl-query-string ;
: vector-unit ( -- n ) { 6 13 } sysctl-query-uint ;
: bus-frequency ( -- n ) { 6 14 } sysctl-query-uint ;
M: macosx cpu-mhz ( -- n ) { 6 15 } sysctl-query-uint ;
: cacheline-size ( -- n ) { 6 16 } sysctl-query-uint ;
: l1-icache-size ( -- n ) { 6 17 } sysctl-query-uint ;
: l1-dcache-size ( -- n ) { 6 18 } sysctl-query-uint ;
: l2-cache-settings ( -- n ) { 6 19 } sysctl-query-uint ;
: l2-cache-size ( -- n ) { 6 20 } sysctl-query-uint ;
: l3-cache-settings ( -- n ) { 6 21 } sysctl-query-uint ;
: l3-cache-size ( -- n ) { 6 22 } sysctl-query-uint ;
: tb-frequency ( -- n ) { 6 23 } sysctl-query-uint ;
: mem-size ( -- n ) { 6 24 } sysctl-query-ulonglong ;
: available-cpus ( -- n ) { 6 25 } sysctl-query-uint ;
