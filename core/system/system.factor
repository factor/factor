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

: vm-git-ref ( -- string )
    vm-git-label "-" split1-last drop ;

: vm-git-id ( -- string )
    vm-git-label "-" split1-last nip ;

: vm-compiler ( -- string ) \ vm-compiler get-global ;

: vm-compile-time ( -- string ) \ vm-compile-time get-global ;

<PRIVATE

CONSTANT: string>cpu-hash H{
    { "x86.32" x86.32 }
    { "x86.64" x86.64 }
    { "arm.32" arm.32 }
    { "arm.64" arm.64 }
    { "ppc.32" ppc.32 }
    { "ppc.64" ppc.64 }
}

CONSTANT: string>os-hash H{
    { "windows" windows }
    { "macosx" macosx }
    { "freebsd" freebsd }
    { "linux" linux }
}

: string>cpu ( str -- class )
    string>cpu-hash at ;

: string>os ( str -- class )
    string>os-hash at ;

PRIVATE>

: image-path ( -- path ) \ image-path get-global ;

: vm-path ( -- path ) \ vm-path get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

: version-info ( -- str )
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

: exit ( n -- )
    '[ do-shutdown-hooks _ (exit) ] ignore-errors
    [ "Unexpected error during shutdown!" print flush ] ignore-errors
    255 (exit) ;
