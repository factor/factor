USING: alien alien.c-types alien.libraries alien.syntax io kernel locals math math.parser namespaces prettyprint sequences ;
IN: mips.longlong.probe
<< "mips-longlong" "mips-longlong-library" get cdecl add-library >>
LIBRARY: mips-longlong
FUNCTION: longlong signed_identity ( longlong n )
FUNCTION: ulonglong unsigned_identity ( ulonglong n )
FUNCTION: longlong negative_value ( )
FUNCTION: longlong signed_pair ( int marker, longlong x, longlong y )
0x123456789abcdef dup signed_identity assert=
-0x123456789abcdef dup signed_identity assert=
-0x8000000000000000 dup signed_identity assert=
0xffffffffffffffff dup unsigned_identity assert=
-1099511627769 negative_value assert=
0x123456789abcdef 0x123456789abcdee 1 + +
1 0x123456789abcdef 0x123456789abcdee signed_pair assert=
LIBRARY: libc
FUNCTION-ALIAS: ll-open int open ( c-string path, int flags, int mode )
FUNCTION-ALIAS: ll-seek longlong lseek64 ( int fd, longlong offset, int whence )
FUNCTION-ALIAS: ll-close int close ( int fd )
FUNCTION-ALIAS: ll-unlink int unlink ( c-string path )
FUNCTION-ALIAS: ll-pid int getpid ( )
:: sparse-seek ( -- )
    "/tmp/mips-factor-longlong-" ll-pid number>string append :> path
    path 0x102 0x180 ll-open :> fd
    t fd 0 >= assert=
    4294967297 fd 4294967297 0 ll-seek assert=
    4294967297 fd 0 1 ll-seek assert=
    fd ll-close 0 assert=
    path ll-unlink 0 assert= ;
sparse-seek
"Optimized longlong and sparse lseek64 PASS" print flush
