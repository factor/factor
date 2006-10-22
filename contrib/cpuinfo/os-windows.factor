IN: cpuinfo
USING: alien kernel math win32-api ;

: memory-status ( -- MEMORYSTATUSEX )
    "MEMORYSTATUSEX" <c-object>
    "MEMORYSTATUSEX" c-size over set-MEMORYSTATUSEX-dwLength
    [ GlobalMemoryStatusEx ] keep swap zero? [ win32-error ] when ;

: physical-ram ( -- n )
    memory-status MEMORYSTATUSEX-ullTotalPhys ;

: available-ram ( -- n )
    memory-status MEMORYSTATUSEX-ullAvailPhys ;

: system-info ( -- SYSTEM_INFO )
    "SYSTEM_INFO" <c-object> [ GetSystemInfo ] keep ;

: page-size ( -- n )
    system-info SYSTEM_INFO-dwPageSize ;

: processor# ( -- n )
    system-info SYSTEM_INFO-dwNumberOfProcessors ;

! 386, 486, 586, 2200 (IA64), 8664 (AMD_X8664)
: processor-type ( -- n )
    system-info SYSTEM_INFO-dwProcessorType ;

! 0 = x86, 6 = Intel Itanium, 9 = x64 (AMD or Intel), 10 = WOW64, 0xffff = Unk
: processor-architecture ( -- n )
    system-info SYSTEM_INFO-dwOemId HEX: ffff0000 bitand ;

: os-version
    "OSVERSIONINFO" <c-object>
    "OSVERSIONINFO" c-size over set-OSVERSIONINFO-dwOSVersionInfoSize
    [ GetVersionEx ] keep swap zero? [ win32-error ] when ;

: windows-major ( -- n )
    os-version OSVERSIONINFO-dwMajorVersion ;

: windows-minor ( -- n )
    os-version OSVERSIONINFO-dwMinorVersion ;

: windows-build# ( -- n )
    os-version OSVERSIONINFO-dwBuildNumber ;

: windows-platform-id ( -- n )
    os-version OSVERSIONINFO-dwPlatformId ;

: windows-service-pack ( -- string )
    os-version OSVERSIONINFO-szCSDVersion ;

: sse2? ( -- ? )
    PF_XMMI64_INSTRUCTIONS_AVAILABLE IsProcessorFeaturePresent zero? not ;

