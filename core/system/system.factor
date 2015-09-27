! copyright (c) 2007, 2010 slava pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs continuations init io kernel kernel.private make
math.parser namespaces sequences splitting ;
IN: system

PRIMITIVE: (exit) ( n -- * )
PRIMITIVE: nano-count ( -- ns )

SINGLETONS: x86.32 x86.64 arm ppc.32 ppc.64 ;

UNION: x86 x86.32 x86.64 ;
UNION: ppc ppc.32 ppc.64 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: windows macosx linux ;

UNION: unix macosx linux ;

: os ( -- class ) \ os get-global ; foldable

: vm-version ( -- string ) \ vm-version get-global ; foldable

: vm-git-label ( -- string ) \ vm-git-label get-global ; foldable

: split-vm-git-label ( -- ref git-id )
    vm-git-label "-" split1-last ; foldable

: vm-git-ref ( -- string ) split-vm-git-label drop ; foldable

: vm-git-id ( -- string ) split-vm-git-label nip ; foldable

: vm-compiler ( -- string ) \ vm-compiler get-global ; foldable

: vm-compile-time ( -- string ) \ vm-compile-time get-global ; foldable

<PRIVATE

CONSTANT: string>cpu-hash H{
    { "x86.32" x86.32 }
    { "x86.64" x86.64 }
    { "arm" arm }
    { "ppc.32" ppc.32 }
    { "ppc.64" ppc.64 }
}

CONSTANT: string>os-hash H{
    { "windows" windows }
    { "macosx" macosx }
    { "linux" linux }
}

: key-for-value ( key hash -- val )
    >alist [ second = ] with find nip first ;

: string>cpu ( str -- class )
    string>cpu-hash at ;

: cpu>string ( class -- str )
    string>cpu-hash key-for-value ;

: string>os ( str -- class )
    string>os-hash at ;

: os>string ( class -- str )
    string>os-hash key-for-value ;

PRIVATE>

: image-path ( -- path ) \ image-path get-global ;

: vm-path ( -- path ) \ vm-path get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

: version-info ( -- str )
    ! formatting vocab not available in this context.
    [
        "Factor " % vm-version %
        " " % cpu cpu>string %
        " (" % build # ", " %
        split-vm-git-label [ % "-" % ] [ 10 short head % ] bi* ", " %
        vm-compile-time % ")\n[" %
        vm-compiler % "] on " % os os>string %
    ] "" make ;

: exit ( n -- * )
    [ do-shutdown-hooks (exit) ] ignore-errors
    [ "Unexpected error during shutdown!" print ] ignore-errors
    255 (exit) ;
