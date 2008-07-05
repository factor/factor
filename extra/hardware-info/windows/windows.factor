USING: alien alien.c-types kernel libc math namespaces
windows windows.kernel32 windows.advapi32
words combinators vocabs.loader hardware-info.backend
system alien.strings ;
IN: hardware-info.windows

: system-info ( -- SYSTEM_INFO )
    "SYSTEM_INFO" <c-object> [ GetSystemInfo ] keep ;

: page-size ( -- n )
    system-info SYSTEM_INFO-dwPageSize ;

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
    os-version OSVERSIONINFO-szCSDVersion utf16n alien>string ;

: feature-present? ( n -- ? )
    IsProcessorFeaturePresent zero? not ;

: sse2? ( -- ? )
    PF_XMMI64_INSTRUCTIONS_AVAILABLE feature-present? ;

: sse3? ( -- ? )
    PF_SSE3_INSTRUCTIONS_AVAILABLE feature-present? ;

: <u16-string-object> ( n -- obj )
    "ushort" <c-array> ;

: get-directory ( word -- str )
    >r MAX_UNICODE_PATH [ <u16-string-object> ] keep dupd r>
    execute win32-error=0/f utf16n alien>string ; inline

: windows-directory ( -- str )
    \ GetWindowsDirectory get-directory ;

: system-directory ( -- str )
    \ GetSystemDirectory get-directory ;

: system-windows-directory ( -- str )
    \ GetSystemWindowsDirectory get-directory ;

<<
{
    { [ os wince? ] [ "hardware-info.windows.ce" ] }
    { [ os winnt? ] [ "hardware-info.windows.nt" ] }
} cond [ require ] when* >>
