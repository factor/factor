USING: alien alien.c-types kernel libc math namespaces
windows windows.kernel32 windows.advapi32 hardware-info ;
IN: hardware-info.windows

TUPLE: wince ;
TUPLE: winnt ;
UNION: windows wince winnt ;
USE: system

: system-info ( -- SYSTEM_INFO )
    "SYSTEM_INFO" <c-object> [ GetSystemInfo ] keep ;

: page-size ( -- n )
    system-info SYSTEM_INFO-dwPageSize ;

M: windows cpus ( -- n )
    system-info SYSTEM_INFO-dwNumberOfProcessors ;

! 386, 486, 586, 2200 (IA64), 8664 (AMD_X8664)
: processor-type ( -- n )
    system-info SYSTEM_INFO-dwProcessorType ;

! 0 = x86, 6 = Intel Itanium, 9 = x64 (AMD or Intel), 10 = WOW64, 0xffff = Unk
: processor-architecture ( -- n )
    system-info SYSTEM_INFO-dwOemId HEX: ffff0000 bitand ;

: os-version
    "OSVERSIONINFO" <c-object>
    "OSVERSIONINFO" heap-size over set-OSVERSIONINFO-dwOSVersionInfoSize
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
    os-version OSVERSIONINFO-szCSDVersion alien>u16-string ;

: feature-present? ( n -- ? )
    IsProcessorFeaturePresent zero? not ;

: sse2? ( -- ? )
    PF_XMMI64_INSTRUCTIONS_AVAILABLE feature-present? ;

: sse3? ( -- ? )
    PF_SSE3_INSTRUCTIONS_AVAILABLE feature-present? ;

USE-IF: wince? hardware-info.windows.ce
USE-IF: winnt? hardware-info.windows.nt

