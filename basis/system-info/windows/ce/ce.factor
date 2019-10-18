! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.data system-info kernel math namespaces
windows windows.kernel32 system-info.backend system ;
IN: system-info.windows.ce

: memory-status ( -- MEMORYSTATUS )
    "MEMORYSTATUS" <c-object>
    "MEMORYSTATUS" heap-size over set-MEMORYSTATUS-dwLength
    dup GlobalMemoryStatus ;

M: wince cpus ( -- n ) 1 ;

M: wince memory-load ( -- n )
    memory-status MEMORYSTATUS-dwMemoryLoad ;

M: wince physical-mem ( -- n )
    memory-status MEMORYSTATUS-dwTotalPhys ;

M: wince available-mem ( -- n )
    memory-status MEMORYSTATUS-dwAvailPhys ;

M: wince total-page-file ( -- n )
    memory-status MEMORYSTATUS-dwTotalPageFile ;

M: wince available-page-file ( -- n )
    memory-status MEMORYSTATUS-dwAvailPageFile ;

M: wince total-virtual-mem ( -- n )
    memory-status MEMORYSTATUS-dwTotalVirtual ;

M: wince available-virtual-mem ( -- n )
    memory-status MEMORYSTATUS-dwAvailVirtual ;
