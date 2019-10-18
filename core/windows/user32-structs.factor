! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien parser namespaces kernel syntax words math io prettyprint ;
IN: win32-api

C-STRUCT: TRACKMOUSEEVENT
    { "DWORD" "cbSize" }
    { "DWORD" "dwFlags" }
    { "HWND" "hwndTrack" }
    { "DWORD" "dwHoverTime" } ;
TYPEDEF: TRACKMOUSEEVENT* LPTRACKMOUSEEVENT

