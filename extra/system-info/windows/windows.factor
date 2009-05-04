! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types kernel libc math namespaces
windows windows.kernel32 windows.advapi32
words combinators vocabs.loader system-info.backend
system alien.strings windows.errors ;
IN: system-info.windows

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

: os-version ( -- os-version )
    "OSVERSIONINFO" <c-object>
    "OSVERSIONINFO" heap-size over set-OSVERSIONINFO-dwOSVersionInfoSize
    dup GetVersionEx win32-error=0/f ;

: windows-major ( -- n )
    os-version OSVERSIONINFO-dwMajorVersion ;

: windows-minor ( -- n )
    os-version OSVERSIONINFO-dwMinorVersion ;

: windows-build# ( -- n )
    os-version OSVERSIONINFO-dwBuildNumber ;

: windows-platform-id ( -- n )
    os-version OSVERSIONINFO-dwPlatformId ;

: windows-service-pack ( -- string )
    os-version OSVERSIONINFO-szCSDVersion alien>native-string ;

: feature-present? ( n -- ? )
    IsProcessorFeaturePresent zero? not ;

: sse2? ( -- ? )
    PF_XMMI64_INSTRUCTIONS_AVAILABLE feature-present? ;

: sse3? ( -- ? )
    PF_SSE3_INSTRUCTIONS_AVAILABLE feature-present? ;

: <u16-string-object> ( n -- obj )
    "ushort" <c-array> ;

: get-directory ( word -- str )
    [ MAX_UNICODE_PATH [ <u16-string-object> ] keep dupd ] dip
    execute win32-error=0/f alien>native-string ; inline

: windows-directory ( -- str )
    \ GetWindowsDirectory get-directory ;

: system-directory ( -- str )
    \ GetSystemDirectory get-directory ;

: system-windows-directory ( -- str )
    \ GetSystemWindowsDirectory get-directory ;

<<
{
    { [ os wince? ] [ "system-info.windows.ce" ] }
    { [ os winnt? ] [ "system-info.windows.nt" ] }
} cond require >>
