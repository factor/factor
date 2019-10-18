! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: calendar.windows system time windows.errors
windows.kernel32 kernel classes.struct calendar ;
IN: time.windows

M: windows set-time
    >gmt
    timestamp>SYSTEMTIME SetSystemTime win32-error=0/f ;
