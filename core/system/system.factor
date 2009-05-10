! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private sequences math namespaces
init splitting assocs system.private layouts words ;
IN: system

SINGLETONS: x86.32 x86.64 arm ppc ;

UNION: x86 x86.32 x86.64 ;

: cpu ( -- class ) \ cpu get-global ; foldable

SINGLETONS: winnt wince ;

UNION: windows winnt wince ;

SINGLETONS: freebsd netbsd openbsd solaris macosx linux ;

SINGLETON: haiku

UNION: bsd freebsd netbsd openbsd macosx ;

UNION: unix bsd solaris linux haiku ;

: os ( -- class ) \ os get-global ; foldable

<PRIVATE

: string>cpu ( str -- class )
    H{
        { "x86.32" x86.32 }
        { "x86.64" x86.64 }
        { "arm" arm }
        { "ppc" ppc }
    } at ;

: string>os ( str -- class )
    H{
        { "winnt" winnt }
        { "wince" wince }
        { "freebsd" freebsd }
        { "netbsd" netbsd }
        { "openbsd" openbsd }
        { "solaris" solaris }
        { "macosx" macosx }
        { "linux" linux }
        { "haiku" haiku }
    } at ;

PRIVATE>

: image ( -- path ) \ image get-global ;

: vm ( -- path ) \ vm get-global ;

: embedded? ( -- ? ) 15 getenv ;

: millis ( -- ms ) micros 1000 /i ;
