! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings alien.syntax
classes.struct kernel libc math system system-info unix.users ;
IN: system-info.haiku

LIBRARY: libc

! Haiku r1beta6 OS.h, including fields not exposed by this vocabulary.
STRUCT: haiku-system-info
    { boot-time longlong }
    { cpu-count uint }
    { max-pages ulonglong }
    { used-pages ulonglong }
    { cached-pages ulonglong }
    { block-cache-pages ulonglong }
    { ignored-pages ulonglong }
    { needed-memory ulonglong }
    { free-memory ulonglong }
    { max-swap-pages ulonglong }
    { free-swap-pages ulonglong }
    { page-faults uint }
    { max-sems uint }
    { used-sems uint }
    { max-ports uint }
    { used-ports uint }
    { max-threads uint }
    { used-threads uint }
    { max-teams uint }
    { used-teams uint }
    { kernel-name char[256] }
    { kernel-build-date char[32] }
    { kernel-build-time char[32] }
    { kernel-version longlong }
    { abi uint } ;

STRUCT: haiku-cpu-info
    { active-time longlong }
    { enabled bool }
    { current-frequency ulonglong } ;

STRUCT: haiku-utsname
    { sysname char[32] }
    { nodename char[32] }
    { release char[32] }
    { version char[32] }
    { machine char[32] } ;

FUNCTION-ALIAS: haiku-get-system-info
    int get_system_info ( haiku-system-info* info )
FUNCTION-ALIAS: haiku-get-cpu-info
    int _get_cpu_info_etc ( uint first, uint count, haiku-cpu-info* info, size_t size )
FUNCTION-ALIAS: haiku-uname int uname ( haiku-utsname* info )

<PRIVATE

! The kernel API returns signed status_t directly instead of setting errno.
: check-haiku-status ( status -- )
    dup 0 = [ drop ] [ (throw-errno) ] if ;

: system-information ( -- info )
    haiku-system-info new [ haiku-get-system-info check-haiku-status ] keep ;

: cpu-information ( -- info )
    0 1 haiku-cpu-info new
    [ haiku-cpu-info heap-size haiku-get-cpu-info check-haiku-status ] keep ;

: uname-information ( -- info )
    haiku-utsname new [ haiku-uname io-error ] keep ;

PRIVATE>

! B_PAGE_SIZE is 4096 on the supported x86-64 target.
CONSTANT: haiku-page-size 4096

M: haiku os-version uname-information release>> alien>native-string ;
M: haiku computer-name uname-information nodename>> alien>native-string ;
M: haiku username real-user-name ;
M: haiku cpus system-information cpu-count>> ;
M: haiku cpu-mhz cpu-information current-frequency>> ;
M: haiku physical-mem system-information max-pages>> haiku-page-size * ;
M: haiku available-mem system-information free-memory>> ;
M: haiku memory-load
    system-information [ used-pages>> ] [ max-pages>> ] bi /f 100 * ;
M: haiku total-page-file
    system-information max-swap-pages>> haiku-page-size * ;
M: haiku available-page-file
    system-information free-swap-pages>> haiku-page-size * ;
