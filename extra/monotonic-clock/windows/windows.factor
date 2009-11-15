! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data fry kernel monotonic-clock
system windows.errors windows.kernel32 ;
IN: monotonic-clock.windows

<PRIVATE

: execute-performance-query ( word -- n )
    [ "LARGE_INTEGER*" <c-object> ] dip
    '[ _ execute win32-error=0/f ] keep *ulonglong ; inline

PRIVATE>

M: windows monotonic-count  ( -- n )
    \ QueryPerformanceCounter execute-performance-query ;

: cpu-frequency ( -- n )
    \ QueryPerformanceFrequency execute-performance-query ;
