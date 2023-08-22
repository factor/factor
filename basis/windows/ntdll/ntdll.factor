! Copyright (C) 2013 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct windows.types ;
IN: windows.ntdll

LIBRARY: ntdll

TYPEDEF: uint NTSTATUS

! Buffer is a PWSTR
STRUCT: LSA_UNICODE_STRING
    { Length USHORT }
    { MaximumLength USHORT }
    { Buffer void* } ;
TYPEDEF: LSA_UNICODE_STRING* PLSA_UNICODE_STRING
TYPEDEF: LSA_UNICODE_STRING UNICODE_STRING
TYPEDEF: LSA_UNICODE_STRING* PUNICODE_STRING

STRUCT: RTL_DRIVE_LETTER_CURDIR
    { Flags USHORT }
    { Length USHORT }
    { Timestamp ULONG }
    { DosPath UNICODE_STRING } ;
TYPEDEF: RTL_DRIVE_LETTER_CURDIR* PRTL_DRIVE_LETTER_CURDIR

STRUCT: RTL_USER_PROCESS_PARAMETERS
    { MaximumLength ULONG }
    { Length ULONG }
    { Flags ULONG }
    { DebugFlags ULONG }
    { ConsoleHandle PVOID }
    { ConsoleFlags ULONG }
    { StdInputHandle HANDLE }
    { StdOutputHandle HANDLE }
    { StdErrorHandle HANDLE }
    { CurrentDirectoryPath UNICODE_STRING }
    { CurrentDirectoryHandle HANDLE }
    { DllPath UNICODE_STRING }
    { ImagePathName UNICODE_STRING }
    { CommandLine UNICODE_STRING }
    { Environment PVOID }
    { StartingPositionLeft ULONG }
    { StartingPositionTop ULONG }
    { Width ULONG }
    { Height ULONG }
    { CharWidth ULONG }
    { CharHeight ULONG }
    { ConsoleTextAttributes ULONG }
    { WindowFlags ULONG }
    { ShowWindowFlags ULONG }
    { WindowTitle UNICODE_STRING }
    { DesktopName UNICODE_STRING }
    { ShellInfo UNICODE_STRING }
    { RuntimeData UNICODE_STRING }
    { DLCurrentDirectory RTL_DRIVE_LETTER_CURDIR[0x20] } ;
TYPEDEF: RTL_USER_PROCESS_PARAMETERS* PRTL_USER_PROCESS_PARAMETERS

STRUCT: LIST_ENTRY
    { Flink LIST_ENTRY* }
    { Blink LIST_ENTRY* } ;
TYPEDEF: LIST_ENTRY* PLIST_ENTRY

STRUCT: PEB_LDR_DATA
    { Length ULONG }
    { Initialized BOOLEAN }
    { SsHandle PVOID }
    { InLoadOrderModuleList LIST_ENTRY }
    { InMemoryOrderModuleList LIST_ENTRY }
    { InInitializationOrderModuleList LIST_ENTRY } ;
TYPEDEF: PEB_LDR_DATA* PPEB_LDR_DATA

TYPEDEF: void* PPS_POST_PROCESS_INIT_ROUTINE

STRUCT: PEB_FREE_BLOCK
    { Next PEB_FREE_BLOCK* }
    { Size ULONG } ;
TYPEDEF: PEB_FREE_BLOCK* PPEB_FREE_BLOCK

STRUCT: PEBLOCKROUTINE
    { PebLock PVOID } ;
TYPEDEF: PEBLOCKROUTINE* PPEBLOCKROUTINE

TYPEDEF: PVOID* PPVOID

STRUCT: PEB
    { InheritedAddressSpace BOOLEAN }
    { ReadImageFileExecOptions BOOLEAN }
    { BeingDebugged BOOLEAN }
    { Spare BOOLEAN }
    { Mutant HANDLE }
    { ImageBaseAddress HMODULE }
    { LoaderData PPEB_LDR_DATA }
    { ProcessParameters PRTL_USER_PROCESS_PARAMETERS }
    { SubSystemData PVOID }
    { ProcessHeap HANDLE }
    { FastPebLock PVOID }
    { FastPebLockRoutine PPEBLOCKROUTINE }
    { FastPebUnlockRoutine PPEBLOCKROUTINE }
    { EnvironmentUpdateCount ULONG }
    { KernelCallbackTable PPVOID }
    { EventLogSection PVOID }
    { EventLog PVOID }
    { FreeList PPEB_FREE_BLOCK }
    { TlsExpansionCounter ULONG }
    { TlsBitmap PVOID }
    { TlsBitmapBits ULONG[2] }
    { ReadOnlySharedMemoryBase PVOID }
    { ReadOnlySharedMemoryHeap PVOID }
    { ReadOnlyStaticServerData PPVOID }
    { AnsiCodePageData PVOID }
    { OemCodePageData PVOID }
    { UnicodeCaseTableData PVOID }
    { NumberOfProcessors ULONG }
    { NtGlobalFlag ULONG }
    { Spare2 BYTE[4] }
    { CriticalSectionTimeout LARGE_INTEGER }
    { HeapSegmentReserve ULONG }
    { HeapSegmentCommit ULONG }
    { HeapDeCommitTotalFreeThreshold ULONG }
    { HeapDeCommitFreeBlockThreshold ULONG }
    { NumberOfHeaps ULONG }
    { MaximumNumberOfHeaps ULONG }
    { ProcessHeaps PPVOID* }
    { GdiSharedHandleTable PVOID }
    { ProcessStarterHelper PVOID }
    { GdiDCAttributeList PVOID }
    { LoaderLock PVOID }
    { OSMajorVersion ULONG }
    { OSMinorVersion ULONG }
    { OSBuildNumber ULONG }
    { OSPlatformId ULONG }
    { ImageSubSystem ULONG }
    { ImageSubSystemMajorVersion ULONG }
    { ImageSubSystemMinorVersion ULONG }
    { GdiHandleBuffer ULONG[0x22] }
    { PostProcessInitRoutine ULONG }
    { TlsExpansionBitmap ULONG }
    { TlsExpansionBitmapBits BYTE[0x80] }
    { SessionId ULONG } ;
TYPEDEF: PEB* PPEB

! PebBaseAddress is PPEB
STRUCT: PROCESS_BASIC_INFORMATION
    { ExitStatus PVOID }
    { PebBaseAddress PVOID }
    { AffinityMask PVOID }
    { BasePriority PVOID }
    { UniqueProcessId ULONG_PTR }
    { InheritedFromUniqueProcessId PVOID } ;

ENUM: PROCESSINFOCLASS
    { ProcessBasicInformation 0 }
    { ProcessDebugPort 7 }
    { ProcessWow64Information 26 }
    { ProcessImageFileName 27 } ;

FUNCTION: NTSTATUS NtQueryInformationProcess (
    HANDLE ProcessHandle,
    PROCESSINFOCLASS ProcessInformationClass,
    PVOID ProcessInformation,
    ULONG ProcessInformationLength,
    PULONG ReturnLength
)
