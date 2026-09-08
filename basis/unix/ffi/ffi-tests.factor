USING: accessors alien.c-types alien.utilities continuations
io.encodings.utf8 io.files.unique kernel libc locals sequences tools.test
unix unix.ffi unix.types ;
IN: unix.ffi.tests

{ 80 } [ "http" f getservbyname port>> ntohs ] unit-test

! Aliases seem unreliable. Leave this as an example but don't rely
! on aliases working.
{ } [
    "http" f getservbyname aliases>> utf8 alien>strings drop
] unit-test

{ "http" } [ 80 htons f getservbyport name>> ] unit-test

! Group IDs are unsigned, including IDs above INT_MAX.
{ 4294967294 } [ group new 4294967294 >>gr_gid gr_gid>> ] unit-test

! Sparse files exercise off_t without allocating gigabytes of storage.
:: check-large-truncation ( path -- )
    path O_RDWR 0 open-file :> fd
    [
        fd 0x100000001 ftruncate io-error
        fd 0 SEEK_END lseek 0x100000001 assert=
        path 0x100000003 truncate io-error
        fd 0 SEEK_END lseek 0x100000003 assert=
    ] [ fd close-file ] finally ;

off_t heap-size 8 = [
    { } [ "factor-truncate-" "" [ check-large-truncation ] cleanup-unique-file ] unit-test
] when
