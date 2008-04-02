! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: system
USING: kernel kernel.private sequences math namespaces
init splitting assocs system.private layouts words ;

SINGLETON: x86.32
SINGLETON: x86.64
SINGLETON: arm
SINGLETON: ppc

UNION: x86 x86.32 x86.64 ;

: cpu ( -- class ) \ cpu get ;

SINGLETON: winnt
SINGLETON: wince

UNION: windows winnt wince ;

SINGLETON: freebsd
SINGLETON: netbsd
SINGLETON: openbsd
SINGLETON: solaris
SINGLETON: macosx
SINGLETON: linux

UNION: bsd freebsd netbsd openbsd macosx ;

UNION: unix bsd solaris linux ;

: os ( -- class ) \ os get ;

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
    } at ;

PRIVATE>

[
    8 getenv string>cpu \ cpu set-global
    9 getenv string>os \ os set-global
] "system" add-init-hook

: image ( -- path ) 13 getenv ;

: vm ( -- path ) 14 getenv ;

: win32? ( -- ? )
    os winnt?
    cell 4 = and ; foldable

: win64? ( -- ? )
    os winnt?
    cell 8 = and ; foldable

: embedded? ( -- ? ) 15 getenv ;

: os-envs ( -- assoc )
    (os-envs) [ "=" split1 ] H{ } map>assoc ;

: set-os-envs ( assoc -- )
    [ "=" swap 3append ] { } assoc>map (set-os-envs) ;
