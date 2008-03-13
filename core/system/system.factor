! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: system
USING: kernel kernel.private sequences math namespaces
splitting assocs system.private layouts ;

: cpu ( -- cpu ) 8 getenv ; foldable

: os ( -- os ) 9 getenv ; foldable

: image ( -- path ) 13 getenv ;

: vm ( -- path ) 14 getenv ;

: wince? ( -- ? )
    os "wince" = ; foldable

: winnt? ( -- ? )
    os "winnt" = ; foldable

: windows? ( -- ? )
    wince? winnt? or ; foldable

: win32? ( -- ? )
    winnt? cell 4 = and ; foldable

: win64? ( -- ? )
    winnt? cell 8 = and ; foldable

: macosx? ( -- ? ) os "macosx" = ; foldable

: embedded? ( -- ? ) 15 getenv ;

: unix? ( -- ? )
    os {
        "freebsd" "openbsd" "netbsd" "linux" "macosx" "solaris"
    } member? ;

: bsd? ( -- ? )
    os { "freebsd" "openbsd" "netbsd" "macosx" } member? ;

: linux? ( -- ? )
    os "linux" = ;

: solaris? ( -- ? )
    os "solaris" = ;

: os-envs ( -- assoc )
    (os-envs) [ "=" split1 ] H{ } map>assoc ;

: set-os-envs ( assoc -- )
    [ "=" swap 3append ] { } assoc>map (set-os-envs) ;
