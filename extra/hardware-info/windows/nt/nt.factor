USING: alien alien.c-types
kernel libc math namespaces hardware-info.backend
windows windows.advapi32 windows.kernel32 ;
IN: hardware-info.windows.nt

TUPLE: winnt-os ;
T{ winnt-os } os set-global

: system-info ( -- SYSTEM_INFO )
    "SYSTEM_INFO" <c-object> [ GetSystemInfo ] keep ;

M: winnt-os cpus ( -- n )
    system-info SYSTEM_INFO-dwNumberOfProcessors ;

: memory-status ( -- MEMORYSTATUSEX )
    "MEMORYSTATUSEX" <c-object>
    "MEMORYSTATUSEX" heap-size over set-MEMORYSTATUSEX-dwLength
    [ GlobalMemoryStatusEx ] keep swap zero? [ win32-error ] when ;

M: winnt-os memory-load ( -- n )
    memory-status MEMORYSTATUSEX-dwMemoryLoad ;

M: winnt-os physical-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPhys ;

M: winnt-os available-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPhys ;

M: winnt-os total-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPageFile ;

M: winnt-os available-page-file ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPageFile ;

M: winnt-os total-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalVirtual ;

M: winnt-os available-virtual-mem ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailVirtual ;

: computer-name ( -- string )
    MAX_COMPUTERNAME_LENGTH 1+ [ malloc ] keep
    <int> dupd GetComputerName zero? [
        free win32-error f
    ] [
        [ alien>u16-string ] keep free
    ] if ;
 
: username ( -- string )
    UNLEN 1+ [ malloc ] keep
    <int> dupd GetUserName zero? [
        free win32-error f
    ] [
        [ alien>u16-string ] keep free
    ] if ;
