! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.syntax byte-arrays io
io.encodings.string io.encodings.utf8 io.streams.byte-array
libc kernel sequences splitting strings system system-info unix
unix.linux.proc math unix.users ;
IN: system-info.linux

FUNCTION-ALIAS: (uname)
    int uname ( c-string buf )

: uname ( -- seq )
    65536 <byte-array> [ (uname) io-error ] keep >string
    "\0" split harvest dup length 6 assert= ;

: sysname ( -- string ) 0 uname nth ;
: nodename ( -- string ) 1 uname nth ;
: release ( -- string ) 2 uname nth ;
: version ( -- string ) 3 uname nth ;
: machine ( -- string ) 4 uname nth ;
: domainname ( -- string ) 5 uname nth ;

M: linux os-version release ;
M: linux cpus parse-proc-cpuinfo sort-cpus cpu-counts 2drop ;
: cores ( -- n ) parse-proc-cpuinfo sort-cpus cpu-counts drop nip ;
: hyperthreads ( -- n ) parse-proc-cpuinfo sort-cpus cpu-counts 2nip ;
M: linux cpu-mhz parse-proc-cpuinfo first cpu-mhz>> 1,000,000 * ;
M: linux physical-mem parse-proc-meminfo mem-total>> ;
M: linux computer-name nodename ;
M: linux username real-user-name ;
