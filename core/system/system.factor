! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs continuations init io kernel.private namespaces ;
IN: system

SINGLETONS: x86.32 x86.64 arm ppc.32 ppc.64 ;

UNION: x86 x86.32 x86.64 ;
UNION: ppc ppc.32 ppc.64 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: windows macosx linux ;

UNION: unix macosx linux ;

: os ( -- class ) \ os get-global ; foldable

: vm-compiler ( -- string ) \ vm-compiler get-global ; foldable

<PRIVATE

: string>cpu ( str -- class )
    H{
        { "x86.32" x86.32 }
        { "x86.64" x86.64 }
        { "arm" arm }
        { "ppc.32" ppc.32 }
        { "ppc.64" ppc.64 }
    } at ;

: string>os ( str -- class )
    H{
        { "windows" windows }
        { "macosx" macosx }
        { "linux" linux }
    } at ;

PRIVATE>

: image ( -- path ) \ image get-global ;

: vm ( -- path ) \ vm get-global ;

: install-prefix ( -- path ) \ install-prefix get-global ;

: embedded? ( -- ? ) OBJ-EMBEDDED special-object ;

: exit ( n -- * )
    [ do-shutdown-hooks (exit) ] ignore-errors
    [ "Unexpected error during shutdown!" print ] ignore-errors
    255 (exit) ;
