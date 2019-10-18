! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.strings
arrays byte-arrays classes.struct combinators kernel math
namespaces specialized-arrays system
vocabs.loader windows windows.advapi32
windows.errors windows.kernel32 words system-info ;
SPECIALIZED-ARRAY: ushort
IN: system-info.windows

: system-info ( -- SYSTEM_INFO )
    SYSTEM_INFO <struct> [ GetSystemInfo ] keep ;

: page-size ( -- n )
    system-info dwPageSize>> ;

! 386, 486, 586, 2200 (IA64), 8664 (AMD_X8664)
: processor-type ( -- n )
    system-info dwProcessorType>> ;

! 0 = x86, 6 = Intel Itanium, 9 = x64 (AMD or Intel), 10 = WOW64, 0xffff = Unk
: processor-architecture ( -- n )
    system-info dwOemId>> 0xffff0000 bitand ;

: os-version-struct ( -- os-version )
    OSVERSIONINFO <struct>
        OSVERSIONINFO heap-size >>dwOSVersionInfoSize
    dup GetVersionEx win32-error=0/f ;

: windows-major ( -- n )
    os-version-struct dwMajorVersion>> ;

: windows-minor ( -- n )
    os-version-struct dwMinorVersion>> ;

M: windows os-version ( -- obj )
    os-version-struct [ dwMajorVersion>> ] [ dwMinorVersion>> ] bi 2array ;

: windows-build# ( -- n )
    os-version-struct dwBuildNumber>> ;

: windows-platform-id ( -- n )
    os-version-struct dwPlatformId>> ;

: windows-service-pack ( -- string )
    os-version-struct szCSDVersion>> alien>native-string ;

: feature-present? ( n -- ? )
    IsProcessorFeaturePresent zero? not ;

: sse2? ( -- ? )
    PF_XMMI64_INSTRUCTIONS_AVAILABLE feature-present? ;

: sse3? ( -- ? )
    PF_SSE3_INSTRUCTIONS_AVAILABLE feature-present? ;

: get-directory ( word -- str )
    [ MAX_UNICODE_PATH [ ushort <c-array> ] keep dupd ] dip
    execute win32-error=0/f alien>native-string ; inline

: windows-directory ( -- str )
    \ GetWindowsDirectory get-directory ;

: system-directory ( -- str )
    \ GetSystemDirectory get-directory ;

: system-windows-directory ( -- str )
    \ GetSystemWindowsDirectory get-directory ;

M: windows cpus ( -- n )
    system-info dwNumberOfProcessors>> ;

: memory-status ( -- MEMORYSTATUSEX )
    MEMORYSTATUSEX <struct>
    MEMORYSTATUSEX heap-size >>dwLength
    dup GlobalMemoryStatusEx win32-error=0/f ;

M: windows memory-load ( -- n )
    memory-status dwMemoryLoad>> ;

M: windows physical-mem ( -- n )
    memory-status ullTotalPhys>> ;

M: windows available-mem ( -- n )
    memory-status ullAvailPhys>> ;

M: windows total-page-file ( -- n )
    memory-status ullTotalPageFile>> ;

M: windows available-page-file ( -- n )
    memory-status ullAvailPageFile>> ;

M: windows total-virtual-mem ( -- n )
    memory-status ullTotalVirtual>> ;

M: windows available-virtual-mem ( -- n )
    memory-status ullAvailVirtual>> ;

M: windows computer-name ( -- string )
    MAX_COMPUTERNAME_LENGTH 1 +
    [ <byte-array> dup ] keep uint <ref>
    GetComputerName win32-error=0/f alien>native-string ;

: username ( -- string )
    UNLEN 1 +
    [ <byte-array> dup ] keep uint <ref>
    GetUserName win32-error=0/f alien>native-string ;
