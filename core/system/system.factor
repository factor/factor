! Copyright (c) 2007, 2010 slava pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs continuations init io kernel
kernel.private make math.parser namespaces sequences splitting ;
IN: system

PRIMITIVE: (exit) ( n -- * )
PRIMITIVE: disable-ctrl-break ( -- )
PRIMITIVE: enable-ctrl-break ( -- )
PRIMITIVE: nano-count ( -- ns )

SINGLETONS: x86.32 x86.64 arm.32 arm.64 ppc.32 ppc.64 ;

UNION: x86 x86.32 x86.64 ;
UNION: arm arm.32 arm.64 ;
UNION: ppc ppc.32 ppc.64 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: windows macosx linux freebsd ;

UNION: bsd freebsd ;
UNION: unix macosx linux freebsd bsd ;

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
    } at ;

: string>os ( str -- class )
    H{
        { "windows" windows }
        { "macosx" macosx }
        { "freebsd" freebsd }
        { "linux" linux }
    } at ;

PRIVATE>

: image-path ( -- path ) \ image-path get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

: exit ( n -- * )
    [ do-shutdown-hooks (exit) ] ignore-errors
    [ "Unexpected error during shutdown!" print flush ] ignore-errors
    255 (exit) ;

: quit ( -- * ) 0 exit ;
