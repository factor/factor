USING: alien.c-types hardware-info kernel math namespaces
windows windows.kernel32 hardware-info.backend ;
IN: hardware-info.windows.ce

TUPLE: wince-os ;
T{ wince-os } os set-global

: memory-status ( -- MEMORYSTATUS )
    "MEMORYSTATUS" <c-object>
    "MEMORYSTATUS" heap-size over set-MEMORYSTATUS-dwLength
    [ GlobalMemoryStatus ] keep ;

M: wince-os cpus ( -- n ) 1 ;

M: wince-os memory-load ( -- n )
    memory-status MEMORYSTATUS-dwMemoryLoad ;

M: wince-os physical-mem ( -- n )
    memory-status MEMORYSTATUS-dwTotalPhys ;

M: wince-os available-mem ( -- n )
    memory-status MEMORYSTATUS-dwAvailPhys ;

M: wince-os total-page-file ( -- n )
    memory-status MEMORYSTATUS-dwTotalPageFile ;

M: wince-os available-page-file ( -- n )
    memory-status MEMORYSTATUS-dwAvailPageFile ;

M: wince-os total-virtual-mem ( -- n )
    memory-status MEMORYSTATUS-dwTotalVirtual ;

M: wince-os available-virtual-mem ( -- n )
    memory-status MEMORYSTATUS-dwAvailVirtual ;
