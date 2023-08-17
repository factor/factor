! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io.directories kernel sequences system ;
IN: mason.release.dlls

HOOK: dll-list os ( -- seq )

M: object dll-list { } ;

! These files should be in the directory that mason is run from.
! e.g. c:\factor32 or c:\factor64 on the build machine.

! Sqlite win64: https://synopse.info/files/SQLite3-64.7z
M: windows dll-list
    cpu x86.64 = {
        "resource:libcrypto-3-x64.dll"
        "resource:libssl-3-x64.dll"
    } {
        "resource:libcrypto-3.dll"
        "resource:libssl-3.dll"
    } ? {
        "resource:libtls-10.dll"
        "resource:sqlite3.dll"
    } append ;

: copy-dlls ( -- )
    dll-list [
        "factor" copy-files-into
    ] unless-empty ;
