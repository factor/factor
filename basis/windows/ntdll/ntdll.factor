! Copyright (C) 2013 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax classes.struct windows.types ;
IN: windows.ntdll

LIBRARY: ntdll

TYPEDEF: uint NTSTATUS

STRUCT: LSA_UNICODE_STRING
    { Length USHORT }
    { MaximumLength USHORT }
    { Buffer void* } ;
TYPEDEF: LSA_UNICODE_STRING* PLSA_UNICODE_STRING
TYPEDEF: LSA_UNICODE_STRING UNICODE_STRING
TYPEDEF: LSA_UNICODE_STRING* PUNICODE_STRING

STRUCT: RTL_USER_PROCESS_PARAMETERS
    { Reserved1 BYTE[16] }
    { Reserved2 PVOID[10] }
    { ImagePathName UNICODE_STRING }
    { CommandLine UNICODE_STRING } ;
TYPEDEF: RTL_USER_PROCESS_PARAMETERS* PRTL_USER_PROCESS_PARAMETERS

STRUCT: LIST_ENTRY
    { Flink LIST_ENTRY* }
    { Blink LIST_ENTRY* } ;
TYPEDEF: LIST_ENTRY* PLIST_ENTRY

STRUCT: PEB_LDR_DATA
    { Reserved1 BYTE[8] }
    { Reserved2 PVOID[3] }
    { InMemoryOrderModuleList LIST_ENTRY } ;
TYPEDEF: PEB_LDR_DATA* PPEB_LDR_DATA

TYPEDEF: void* PPS_POST_PROCESS_INIT_ROUTINE

STRUCT: PEB
    { Reserved1 BYTE[2] }
    { BeingDebugged BYTE }
    { Reserved2 BYTE[1] }
    { Reserved3 BYTE[2] }
    { Ldr PPEB_LDR_DATA }
    { ProcessParameters PRTL_USER_PROCESS_PARAMETERS }
    { Reserved4 BYTE[104] }
    { Reserved5 PVOID[52] }
    { PostProcessInitRoutine PPS_POST_PROCESS_INIT_ROUTINE }
    { Reserved6 BYTE[128] }
    { Reserved7 PVOID[1] }
    { SessionId ULONG } ;
TYPEDEF: PEB* PPEB

! PebBaseAddress is PPEB
STRUCT: PROCESS_BASIC_INFORMATION
    { Reserved1 PVOID }
    { PebBaseAddress void* }
    { Reserved2 PVOID[2] } 
    { UniqueProcessId ULONG_PTR }
    { Reserved3 PVOID } ;
    
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
) ;