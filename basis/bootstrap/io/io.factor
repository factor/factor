USING: accessors combinators kernel namespaces parser sequences system vocabs ;
IN: bootstrap.io

"bootstrap.compiler" require
"bootstrap.threads" require

! Older MIPS diagnostic images may have cached generic Linux ABI bindings.
! Refresh them with the optimizer active so native call sites stay compiled.
cpu mips? os linux? and [
    "libc.linux" require
    "resource:basis/libc/linux/linux.factor" run-file
    "unix.ffi" require
    "resource:basis/unix/ffi/linux/linux.factor" run-file
    "unix.signals" require
    "resource:basis/unix/signals/signals.factor" run-file
    ! Initialize environment before unix.process imports environment.unix.
    ! Its startup hook needs the Unix methods to have finished loading.
    "environment" require
    "unix.process" require
    "resource:basis/unix/process/process.factor" run-file
] when

{
    { [ "io-backend" get ] [ "io.backend." "io-backend" get append ] }
    { [ os unix? ] [ "io.backend.unix." os name>> append ] }
    { [ os windows? ] [ "io.backend.windows" ] }
} cond require
