! Linux layout oracles are separate from the portable RISC-V calling convention tests.
USING: accessors alien alien.c-types alien.libraries alien.syntax classes.struct
combinators io.pathnames kernel sequences tools.test unix.linux.epoll unix.statvfs.linux ;
IN: compiler.tests.riscv-linux-layout

<< "riscv-abi" "resource:libfactor-ffi-test.so" absolute-path cdecl add-library >>
LIBRARY: riscv-abi

FUNCTION: size_t rv_sizeof_epoll_event ( )
FUNCTION: size_t rv_offsetof_epoll_data ( )
FUNCTION: size_t rv_sizeof_statvfs ( )
FUNCTION: size_t rv_offsetof_statvfs_flag ( )
FUNCTION: size_t rv_offsetof_statvfs_namemax ( )
FUNCTION: ulong rv_statvfs_flag ( c-string path )
FUNCTION: ulong rv_statvfs_namemax ( c-string path )

{ t } [ epoll-event heap-size rv_sizeof_epoll_event = ] unit-test
{ t } [
    epoll-event lookup-c-type fields>> second offset>> rv_offsetof_epoll_data =
] unit-test

{ t } [ \ statvfs64 heap-size rv_sizeof_statvfs = ] unit-test
{ t } [ "f_flag" \ statvfs64 offset-of rv_offsetof_statvfs_flag = ] unit-test
{ t } [ "f_namemax" \ statvfs64 offset-of rv_offsetof_statvfs_namemax = ] unit-test
{ t t } [
    \ statvfs64 new "/" over statvfs64 0 assert=
    [ f_flag>> "/" rv_statvfs_flag = ]
    [ f_namemax>> "/" rv_statvfs_namemax = ] bi
] unit-test
