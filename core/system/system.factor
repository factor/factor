! Copyright (c) 2007, 2010 slava pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations init io kernel
kernel.private make math.parser namespaces sequences splitting ;
IN: system

PRIMITIVE: (exit) ( n -- * )
PRIMITIVE: disable-ctrl-break ( -- )
PRIMITIVE: enable-ctrl-break ( -- )
PRIMITIVE: nano-count ( -- ns )

SINGLETONS: x86.32 x86.64 arm.32 arm.64 ppc.32 ppc.64 ppc.64le riscv.32 riscv.64 sparc.32 sparc.64 mips.32 mipsel.32 mips.64 mipsel.64 m68k.32 s390x alpha.64 loongarch.64 hppa.32 m88k.32 vax.32 sh3.32 sh4.32 sh3be.32 sh4be.32 ;

UNION: x86 x86.32 x86.64 ;
UNION: arm arm.32 arm.64 ;
UNION: ppc64 ppc.64 ppc.64le ;
UNION: ppc ppc.32 ppc64 ;
UNION: riscv riscv.32 riscv.64 ;
UNION: sparc sparc.32 sparc.64 ;
UNION: mips32 mips.32 mipsel.32 ;
UNION: mips64 mips.64 mipsel.64 ;
UNION: mips mips32 mips64 ;
UNION: m68k m68k.32 ;
UNION: hppa hppa.32 ;
UNION: m88k m88k.32 ;
UNION: vax vax.32 ;
UNION: sh3 sh3.32 sh3be.32 ;
UNION: sh4 sh4.32 sh4be.32 ;
UNION: sh sh3 sh4 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: windows macos linux freebsd netbsd openbsd dragonflybsd haiku ;

UNION: bsd freebsd netbsd openbsd dragonflybsd ;
UNION: unix macos linux bsd haiku ;

: os ( -- class ) \ os get-global ; foldable

: vm-version ( -- string ) \ vm-version get-global ;

: vm-git-label ( -- string ) \ vm-git-label get-global ;

: vm-git-ref ( -- string ) vm-git-label "-" split1-last drop ;

: vm-git-id ( -- string ) vm-git-label "-" split1-last nip ;

: vm-compiler ( -- string ) \ vm-compiler get-global ;

: vm-compile-time ( -- string ) \ vm-compile-time get-global ;

: vm-info ( -- str )
    ! formatting vocab not available in this context.
    [
        "Factor " % vm-version %
        " " % cpu name>> %
        " (" % build # ", " %
        vm-git-ref % "-" %
        vm-git-id 10 index-or-length head % ", " %
        vm-compile-time % ")\n[" %
        vm-compiler % "] on " % os name>> %
    ] "" make ;

: vm-path ( -- path ) \ vm-path get-global ;

<PRIVATE

: string>cpu ( str -- class )
    H{
        { "x86.32" x86.32 }
        { "x86.64" x86.64 }
        { "arm.32" arm.32 }
        { "arm.64" arm.64 }
        { "ppc.32" ppc.32 }
        { "ppc.64" ppc.64 }
        { "ppc.64le" ppc.64le }
        { "riscv.32" riscv.32 }
        { "riscv.64" riscv.64 }
        { "loongarch.64" loongarch.64 }
        { "sparc.32" sparc.32 }
        { "sparc.64" sparc.64 }
        { "mips.32" mips.32 }
        { "mipsel.32" mipsel.32 }
        { "mips.64" mips.64 }
        { "mipsel.64" mipsel.64 }
        { "m68k.32" m68k.32 }
        { "sh3.32" sh3.32 }
        { "sh4.32" sh4.32 }
        { "sh3be.32" sh3be.32 }
        { "sh4be.32" sh4be.32 }
        { "alpha.64" alpha.64 }
        { "vax.32" vax.32 }
        { "s390x" s390x }
        { "hppa.32" hppa.32 }
        { "m88k.32" m88k.32 }
    } at ;

: string>os ( str -- class )
    H{
        { "windows" windows }
        { "macos" macos }
        { "freebsd" freebsd }
        { "netbsd" netbsd }
        { "openbsd" openbsd }
        { "dragonflybsd" dragonflybsd }
        { "dragonfly" dragonflybsd }
        { "linux" linux }
        { "haiku" haiku }
    } at ;

PRIVATE>

: image-path ( -- path ) \ image-path get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

<PRIVATE

: flush-exit-stream ( stream/f -- )
    [ '[ _ stream-flush ] ignore-errors ] when* ;

: flush-exit-streams ( -- )
    output-stream get flush-exit-stream
    error-stream get flush-exit-stream
    output-stream get-global flush-exit-stream
    error-stream get-global flush-exit-stream ;

PRIVATE>

: exit ( n -- * )
    [
        flush-exit-streams
        do-shutdown-hooks
        flush-exit-streams
        (exit)
    ] ignore-errors
    [ "Unexpected error during shutdown!" print flush ] ignore-errors
    flush-exit-streams
    255 (exit) ;

: quit ( -- * ) 0 exit ;
