! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data arrays classes.struct kernel
windows.errors windows.shcore windows.types windows.user32 ;
IN: windows.screens

: get-dpi ( -- dpi )
    0 0 POINT <struct-boa> 0 MonitorFromPoint
    MDT_EFFECTIVE_DPI 
    0 uint <ref> 0 uint <ref> [ GetDpiForMonitor win32-error=0/f ] 2keep
    [ uint deref ] bi@ 2array ;
