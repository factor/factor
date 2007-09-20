! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: system
USING: kernel kernel.private sequences math namespaces ;

: cell ( -- n ) 7 getenv ; foldable

: cells ( m -- n ) cell * ; inline

: cell-bits ( -- n ) 8 cells ; inline

: cpu ( -- cpu ) 8 getenv ; foldable

: os ( -- os ) 9 getenv ; foldable

: image ( -- path ) 13 getenv ;

: vm ( -- path ) 14 getenv ;

: wince? ( -- ? )
    os "wince" = ; foldable

: winnt? ( -- ? )
    os "windows" = ; foldable

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
        "freebsd" "openbsd" "linux" "macosx" "solaris"
    } member? ;

: bsd? ( -- ? )
    os { "freebsd" "openbsd" "macosx" } member? ;

: linux? ( -- ? )
    os "linux" = ;

: solaris? ( -- ? )
    os "solaris" = ;

: bootstrap-cell \ cell get cell or ; inline

: bootstrap-cells bootstrap-cell * ; inline

: bootstrap-cell-bits 8 bootstrap-cells ; inline
