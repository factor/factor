! Copyright (C) 2008 Doug Coleman, John Benediktsson.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data alien.strings alien.syntax arrays
assocs byte-arrays core-foundation endian io.encodings.utf8 kernel
libc sequences splitting system system-info unix.sysctl unix.users ;
IN: system-info.macos

<PRIVATE

TYPEDEF: SInt16 OSErr
TYPEDEF: UInt32 OSType
FUNCTION: OSErr Gestalt ( OSType selector, SInt32* response )

: gestalt ( selector -- response )
    { SInt32 } [ Gestalt 0 assert= ] with-out-parameters ;

: system-version ( -- n ) "sysv" be> gestalt ;
: system-version-major ( -- n ) "sys1" be> gestalt ;
: system-version-minor ( -- n ) "sys2" be> gestalt ;
: system-version-bugfix ( -- n ) "sys3" be> gestalt ;

CONSTANT: system-code-names H{
    { { 15 0 } "Sequoia" }
    { { 14 0 } "Sonoma" }
    { { 13 0 } "Ventura" }
    { { 12 0 } "Monterey" }
    { { 11 0 } "Big Sur" }
    { { 10 16 } "Big Sur" }
    { { 10 15 } "Catalina" }
    { { 10 14 } "Mojave" }
    { { 10 13 } "High Sierra" }
    { { 10 12 } "Sierra" }
    { { 10 11 } "El Capitan" }
    { { 10 10 } "Yosemite" }
    { { 10 9 } "Mavericks" }
    { { 10 8 } "Mountain Lion" }
    { { 10 7 } "Lion" }
    { { 10 6 } "Snow Leopard" }
    { { 10 5 } "Leopard" }
    { { 10 4 } "Tiger" }
    { { 10 3 } "Panther" }
    { { 10 2 } "Jaguar" }
    { { 10 1 } "Puma" }
    { { 10 0 } "Cheetah" }
}

: system-code-name ( -- str/f )
    system-version-major
    dup 10 = [ system-version-minor ] [ 0 ] if 2array
    system-code-names at ;

PRIVATE>

M: macos os-version
    system-version-major
    system-version-minor
    system-version-bugfix 3array ;

! See /usr/include/sys/sysctl.h for constants

: machine ( -- str ) { 6 1 } sysctl-query-string ;
: model ( -- str ) { 6 2 } sysctl-query-string ;
M: macos cpus { 6 3 } sysctl-query-uint ;
: byte-order ( -- n ) { 6 4 } sysctl-query-uint ;

! Only an int, not large enough. Deprecated.
! M: macos physical-mem { 6 5 } sysctl-query-int ;
! : user-mem ( -- n ) { 6 6 } sysctl-query-uint ;

: page-size ( -- n ) { 6 7 } sysctl-query-uint ;
: disknames ( -- n ) { 6 8 } 8 sysctl-query ;
: diskstats ( -- n ) { 6 9 } 8 sysctl-query ;
: epoch ( -- n ) { 6 10 } sysctl-query-uint ;
: floating-point ( -- n ) { 6 11 } sysctl-query-uint ;
: machine-arch ( -- n ) { 6 12 } sysctl-query-string ;
: vector-unit ( -- n ) { 6 13 } sysctl-query-uint ;
: bus-frequency ( -- n ) { 6 14 } sysctl-query-uint ;
M: macos cpu-mhz { 6 15 } sysctl-query-uint ;
: cacheline-size ( -- n ) { 6 16 } sysctl-query-uint ;
: l1-icache-size ( -- n ) { 6 17 } sysctl-query-uint ;
: l1-dcache-size ( -- n ) { 6 18 } sysctl-query-uint ;
: l2-cache-settings ( -- n ) { 6 19 } sysctl-query-uint ;
: l2-cache-size ( -- n ) { 6 20 } sysctl-query-uint ;
: l3-cache-settings ( -- n ) { 6 21 } sysctl-query-uint ;
: l3-cache-size ( -- n ) { 6 22 } sysctl-query-uint ;
: tb-frequency ( -- n ) { 6 23 } sysctl-query-uint ;
M: macos physical-mem { 6 24 } sysctl-query-ulonglong ;
: available-cpus ( -- n ) { 6 25 } sysctl-query-uint ;

M: macos computer-name { 1 10 } sysctl-query-string "." split1 drop ;
M: macos username real-user-name ;
