! Copyright (C) 2016 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io.directories kernel sequences system ;
IN: mason.release.dlls

HOOK: dll-list os ( -- seq )

M: object dll-list { } ;

! These files should be in the directory that mason is run from.
! e.g. c:\factor32 or c:\factor64 on the build machine.

! Sqlite win64: http://synopse.info/files/SQLite3-64.7z
M: windows dll-list
    {
        "resource:libcrypto-37.dll"
        "resource:libssl-38.dll"
        "resource:libtls-10.dll"
        "resource:sqlite3.dll"
    } ;

: copy-dlls ( -- )
    dll-list [
        "factor" copy-files-into
    ] unless-empty ;
