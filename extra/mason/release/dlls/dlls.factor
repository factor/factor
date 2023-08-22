! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories io.pathnames kernel namespaces sequences system ;
IN: mason.release.dlls

HOOK: dll-list os ( -- seq )

M: object dll-list { } ;

! These files should be in the directory that mason is run from.
! e.g. c:\factor32 or c:\factor64 on the build machine.

INITIALIZED-SYMBOL: dll-root [ "resource:" ]

M: windows dll-list
    cpu x86.64 =
    { "libcrypto-3-x64.dll" "libssl-3-x64.dll" }
    { "libcrypto-3.dll" "libssl-3.dll" } ?
    { "sqlite3.dll" } append ;

: dll-paths ( -- seq )
    dll-root get dll-list [ append-relative-path ] with map ;

: copy-dlls ( -- )
    dll-paths [ "factor" copy-files-into ] unless-empty ;
