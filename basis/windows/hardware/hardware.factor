! Copyright (C) 2021 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien arrays io kernel namespaces prettyprint
ui.backend.windows ui.gadgets.worlds windows.errors windows.types
windows.user32 ;
IN: windows.hardware

: monitor-enum-proc ( -- callback )
    BOOL { HMONITOR HDC LPRECT LPARAM } stdcall [
        4dup 4array .
        3drop
        MONITORINFOEX new dup byte-length >>cbSize
        [ GetMonitorInfo win32-error=0/f ] keep ... flush
        TRUE
    ] alien-callback ;

: enum-monitors ( -- )
    world get
    [ handle>> hDC>> ]
    [ make-RECT ] bi
    monitor-enum-proc
    0
    EnumDisplayMonitors win32-error=0/f ;


: desktop-enum-proc ( -- callback )
    BOOL { LPWSTR LPARAM } stdcall [
        2array .
        TRUE
    ] alien-callback ;

: enum-desktops ( -- )
    f desktop-enum-proc 0 EnumDesktopsW win32-error=0/f ;
