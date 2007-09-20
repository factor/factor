USING: alien alien.c-types alien.syntax byte-arrays kernel
namespaces sequences unix hardware-info ;
IN: hardware-info.macosx

TUPLE: macosx ;
T{ macosx } os set-global

! See /usr/include/sys/sysctl.h for constants

LIBRARY: libc
FUNCTION: int sysctl ( int* name, uint namelen, void* oldp, size_t* oldlenp, void* newp, size_t newlen ) ;

: make-int-array ( seq -- byte-array )
    [ <int> ] map concat ;

: (sysctl-query) ( name namelen oldp oldlenp -- oldp error/f )
    over >r
        f 0 sysctl -1 = [ err_no strerror ] [ f ] if
    r> swap ;

: sysctl-query ( seq n -- byte-array )
    >r [ make-int-array ] keep length r>
    [ <byte-array> ] keep <uint>
    (sysctl-query) [ throw ] when* ;

: sysctl-query-string ( seq -- n )
    4096 sysctl-query alien>char-string ;

: sysctl-query-uint ( seq -- n )
    4 sysctl-query *uint ;

: sysctl-query-ulonglong ( seq -- n )
    8 sysctl-query *ulonglong ;

: machine ( -- str ) { 6 1 } sysctl-query-string ;
: model ( -- str ) { 6 2 } sysctl-query-string ;
M: macosx cpus ( -- n ) { 6 3 } sysctl-query-uint ;
: byte-order ( -- n ) { 6 4 } sysctl-query-uint ;
: user-mem ( -- n ) { 6 4 } sysctl-query-uint ;
: page-size ( -- n ) { 6 7 } sysctl-query-uint ;
: bus-frequency ( -- n ) { 6 14 } sysctl-query-uint ;
: cpu-frequency ( -- n ) { 6 15 } sysctl-query-uint ;
: cacheline-size ( -- n ) { 6 16 } sysctl-query-uint ;
: l1-icache-size ( -- n ) { 6 17 } sysctl-query-uint ;
: l1-dcache-size ( -- n ) { 6 18 } sysctl-query-uint ;
: l2-cache-settings ( -- n ) { 6 19 } sysctl-query-uint ;
: l2-cache-size ( -- n ) { 6 20 } sysctl-query-uint ;
: l3-cache-settings ( -- n ) { 6 21 } sysctl-query-uint ;
: l3-cache-size ( -- n ) { 6 22 } sysctl-query-uint ;
: bus-frequency2 ( -- n ) { 6 23 } sysctl-query-uint ;
M: macosx physical-mem ( -- n ) { 6 24 } sysctl-query-ulonglong ;
: available-cpus ( -- n ) { 6 25 } sysctl-query-uint ;

