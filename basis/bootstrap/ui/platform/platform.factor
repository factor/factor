! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: classes.algebra combinators kernel locals sequences system
vocabs.metadata ;
IN: bootstrap.ui.platform

:: default-ui-backend ( target-os target-cpu -- vocab )
    {
        { [ target-os android? ] [ "ui.backend.android" ] }
        { [ target-os macos? ] [ "ui.backend.cocoa" ] }
        { [ target-os windows? ] [ "ui.backend.windows" ] }
        { [ target-os haiku? ] [ "ui.backend.gtk3" ] }
        { [ target-os freebsd? ] [ "ui.backend.gtk3" ] }
        { [ target-os illumos? ] [ "ui.backend.gtk2" ] }
        { [ target-os linux? ] [
            "ui.backend.gtk4" vocab-architectures
            [ target-cpu swap class<= ] any?
            "ui.backend.gtk4" "ui.backend.gtk3" ?
        ] }
        { [ target-os unix? ] [ "ui.backend.gtk2" ] }
    } cond ;

! The selected backend must install its hook on every supported target OS.
! Linux/FreeBSD retain both historical GTK2 and GTK3 registration paths.
: gtk2-backend-platform? ( target-os -- ? )
    { linux freebsd netbsd openbsd dragonflybsd illumos } member? ;

: gtk3-backend-platform? ( target-os -- ? )
    { linux freebsd haiku } member? ;
