USE: kernel

PROVIDE: core/io/unix
{ +files+ {
    "types.factor"
    { "syscalls-linux.factor" [ os "linux" = ] }
    { "syscalls-bsd.factor" [ os "macosx" = ] }
    { "syscalls-bsd.factor" [ os "freebsd" = ] }
    { "syscalls-bsd.factor" [ os "openbsd" = ] }
    { "syscalls-solaris.factor" [ os "solaris" = ] }
    "syscalls.factor"
    "io.factor"
    "sockets.factor"
    "files.factor"
} }
{ +tests+ { "test.factor" } } ;
