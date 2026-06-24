! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators io.directories kernel sequences system ;
IN: mason.release.dlls

HOOK: dll-list os ( -- seq )

M: object dll-list { } ;

! These files should be in the directory that mason is run from.
! e.g. c:\factor32 or c:\factor64 on the build machine.

! Sqlite win64: https://synopse.info/files/SQLite3-64.7z
: windows-openssl-dll-list ( -- seq )
    cpu {
        { x86.64 [ {
            "resource:libcrypto-3-x64.dll"
            "resource:libssl-3-x64.dll"
        } ] }
        { arm.64 [ {
            "resource:libcrypto-3-arm64.dll"
            "resource:libssl-3-arm64.dll"
        } ] }
        [ drop {
            "resource:libcrypto-3.dll"
            "resource:libssl-3.dll"
        } ]
    } case ;

M: windows dll-list
    windows-openssl-dll-list {
        "resource:sqlite3.dll"
    } append ;

: copy-dlls ( -- )
    dll-list [
        "factor" copy-files-into
    ] unless-empty ;
