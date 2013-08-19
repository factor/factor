! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs init kernel kernel.private namespaces strings sequences ;
IN: system

SINGLETONS: x86.32 x86.64 arm ppc.32 ppc.64 ;

UNION: x86 x86.32 x86.64 ;
UNION: ppc ppc.32 ppc.64 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: windows macosx linux ;

UNION: unix macosx linux ;

: os ( -- class ) \ os get-global ; foldable

: version ( -- string ) \ version get-global ; foldable

: git-label ( -- string ) \ git-label get-global ; foldable

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
    >alist [ first2 nip = ] with filter first first ;

: string>cpu ( str -- class )
    string>cpu-hash at ;

: cpu>string ( class -- str )
    string>cpu-hash key-for-value ;

: string>os ( str -- class )
    string>os-hash at ;

: os>string ( class -- str )
    string>os-hash key-for-value ;

PRIVATE>

: image ( -- path ) \ image get-global ;

: vm ( -- path ) \ vm get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

: exit ( n -- * ) do-shutdown-hooks (exit) ;

: version-info ( -- str )
    ! formatting vocab not available in this context.
    "Factor " version append " (" append git-label append ", " append
    vm-compile-time append ") [" append vm-compiler append
    " " append cpu cpu>string append "] on " append os os>string append ;
