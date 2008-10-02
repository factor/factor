! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel cocoa.nibs cocoa.application cocoa ;
IN: cocoa.standalone

: cocoa-app ( quot -- )
    [
        "MiniFactor.nib" load-nib
        call
        finish-launching
        NSApp -> run
    ] with-cocoa ; inline
