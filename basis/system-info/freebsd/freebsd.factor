! Copyright (C) 2022 Alex Maestas
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax byte-arrays grouping kernel
libc math sequences splitting strings system system-info
unix.sysctl unix.users ;
IN: system-info.freebsd

! From /usr/include/sys/utsname.h and as of FreeBSD-13, struct utsname
! is a block of 5 names; __xuname accepts a base length for each item,
! so we can allocate a precise buffer.

CONSTANT: SYS_NMLN 256
CONSTANT: utsname-items 5

<PRIVATE

FUNCTION-ALIAS: (xuname)
    int __xuname ( uint nmln, char *buf )

: (uname) ( nmln -- utsname-seq )
    dup utsname-items * <byte-array>
    [ (xuname) io-error ] keep ;

PRIVATE>

: uname ( -- seq )
    SYS_NMLN [ (uname) ] [ group ] bi
    dup length utsname-items assert=
    [ >string [ zero? ] trim-tail ] map ;

: sysname ( -- string ) 0 uname nth ;
: nodename ( -- string ) 1 uname nth ;
: release ( -- string ) 2 uname nth ;
: version ( -- string ) 3 uname nth ;
: machine ( -- string ) 4 uname nth ;

M: freebsd os-version release ;
M: freebsd cpus { 6 3 } sysctl-query-uint ;
M: freebsd physical-mem { 6 5 } sysctl-query-ulonglong ;
M: freebsd computer-name nodename ;
M: freebsd username real-user-name ;

M: freebsd cpu-mhz
    "dev.cpu.0.freq" sysctl-name-query-uint
    1000 1000 * * ;
