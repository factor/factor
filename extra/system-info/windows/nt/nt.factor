! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types alien.strings
kernel libc math namespaces system-info.backend
system-info.windows windows windows.advapi32
windows.kernel32 system byte-arrays windows.errors ;
IN: system-info.windows.nt

M: winnt cpus ( -- n )
    system-info SYSTEM_INFO-dwNumberOfProcessors ;

: memory-status ( -- MEMORYSTATUSEX )
    "MEMORYSTATUSEX" <c-object>
    "MEMORYSTATUSEX" heap-size over set-MEMORYSTATUSEX-dwLength
    dup GlobalMemoryStatusEx win32-error=0/f ;

M: winnt memory-load ( -- n )
    memory-status MEMORYSTATUSEX-dwMemoryLoad ;

M: winnt physical-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPhys ;

M: winnt available-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPhys ;

M: winnt total-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPageFile ;

M: winnt available-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPageFile ;

M: winnt total-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalVirtual ;

M: winnt available-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailVirtual ;

: computer-name ( -- string )
    MAX_COMPUTERNAME_LENGTH 1+
    [ <byte-array> dup ] keep <uint>
    GetComputerName win32-error=0/f alien>native-string ;
 
: username ( -- string )
    UNLEN 1 +
    [ <byte-array> dup ] keep <uint>
    GetUserName win32-error=0/f alien>native-string ;
