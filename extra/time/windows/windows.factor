! Copyright (C) 2010 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: calendar calendar.windows system time windows.errors
windows.kernel32 ;
IN: time.windows

M: windows set-system-time
    >gmt timestamp>SYSTEMTIME SetSystemTime win32-error=0/f ;
