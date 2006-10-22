IN: win32-api

USING: alien kernel ;

BEGIN-STRUCT: overlapped-ext
    FIELD: int internal
    FIELD: int internal-high
    FIELD: int offset
    FIELD: int offset-high
    FIELD: void* event
    FIELD: int user-data
END-STRUCT

BEGIN-STRUCT: SYSTEMTIME
    FIELD: WORD wYear
    FIELD: WORD wMonth
    FIELD: WORD wDayOfWeek
    FIELD: WORD wDay
    FIELD: WORD wHour
    FIELD: WORD wMinute
    FIELD: WORD wSecond
    FIELD: WORD wMilliseconds
END-STRUCT

BEGIN-STRUCT: TIME_ZONE_INFORMATION
    FIELD: LONG Bias
    ! FIELD: WCHAR[32] StandardName
    FIELD: int a0
    FIELD: int a1
    FIELD: int a2
    FIELD: int a3
    FIELD: int a4
    FIELD: int a5
    FIELD: int a6
    FIELD: int a7
    FIELD: int a8
    FIELD: int a9
    FIELD: int a10
    FIELD: int a11
    FIELD: int a12
    FIELD: int a13
    FIELD: int a14
    FIELD: int a15
    FIELD: SYSTEMTIME StandardDate
    FIELD: LONG StandardBias
    ! FIELD: WCHAR[32] DaylightName
    FIELD: int b0
    FIELD: int b1
    FIELD: int b2
    FIELD: int b3
    FIELD: int b4
    FIELD: int b5
    FIELD: int b6
    FIELD: int b7
    FIELD: int b8
    FIELD: int b9
    FIELD: int b10
    FIELD: int b11
    FIELD: int b12
    FIELD: int b13
    FIELD: int b14
    FIELD: int b15
    FIELD: SYSTEMTIME DaylightDate
    FIELD: LONG DaylightBias
END-STRUCT


BEGIN-STRUCT: FILETIME
    FIELD: DWORD dwLowDateTime
    FIELD: DWORD dwHighDateTime
END-STRUCT

BEGIN-STRUCT: STARTUPINFO
    FIELD: DWORD cb
    FIELD: LPTSTR lpReserved
    FIELD: LPTSTR lpDesktop
    FIELD: LPTSTR lpTitle
    FIELD: DWORD dwX
    FIELD: DWORD dwY
    FIELD: DWORD dwXSize
    FIELD: DWORD dwYSize
    FIELD: DWORD dwXCountChars
    FIELD: DWORD dwYCountChars
    FIELD: DWORD dwFillAttribute
    FIELD: DWORD dwFlags
    FIELD: WORD wShowWindow
    FIELD: WORD cbReserved2
    FIELD: LPBYTE lpReserved2
    FIELD: HANDLE hStdInput
    FIELD: HANDLE hStdOutput
    FIELD: HANDLE hStdError
END-STRUCT

TYPEDEF: void* LPSTARTUPINFO

BEGIN-STRUCT: PROCESS_INFORMATION
    FIELD: HANDLE hProcess
    FIELD: HANDLE hThread
    FIELD: DWORD dwProcessId
    FIELD: DWORD dwThreadId
END-STRUCT

BEGIN-STRUCT: SYSTEM_INFO
    FIELD: DWORD dwOemId
    ! FIELD: WORD wProcessorArchitecture
    ! FIELD: WORD wReserved
    FIELD: DWORD dwPageSize
    FIELD: LPVOID lpMinimumApplicationAddress
    FIELD: LPVOID lpMaximumApplicationAddress
    FIELD: DWORD_PTR dwActiveProcessorMask
    FIELD: DWORD dwNumberOfProcessors
    FIELD: DWORD dwProcessorType
    FIELD: DWORD dwAllocationGranularity
    FIELD: WORD wProcessorLevel
    FIELD: WORD wProcessorRevision
END-STRUCT

TYPEDEF: void* LPSYSTEM_INFO

BEGIN-STRUCT: MEMORYSTATUS
    FIELD: DWORD dwLength
    FIELD: DWORD dwMemoryLoad
    FIELD: SIZE_T dwTotalPhys
    FIELD: SIZE_T dwAvailPhys
    FIELD: SIZE_T dwTotalPageFile
    FIELD: SIZE_T dwAvailPageFile
    FIELD: SIZE_T dwTotalVirtual
    FIELD: SIZE_T dwAvailVirtual
END-STRUCT
TYPEDEF: void* LPMEMORYSTATUS

BEGIN-STRUCT: MEMORYSTATUSEX
    FIELD: DWORD dwLength
    FIELD: DWORD dwMemoryLoad
    FIELD: DWORDLONG ullTotalPhys
    FIELD: DWORDLONG ullAvailPhys
    FIELD: DWORDLONG ullTotalPageFile
    FIELD: DWORDLONG ullAvailPageFile
    FIELD: DWORDLONG ullTotalVirtual
    FIELD: DWORDLONG ullAvailVirtual
    FIELD: DWORDLONG ullAvailExtendedVirtual
END-STRUCT
TYPEDEF: void* LPMEMORYSTATUSEX

BEGIN-STRUCT: OSVERSIONINFO
    FIELD: DWORD dwOSVersionInfoSize
    FIELD: DWORD dwMajorVersion
    FIELD: DWORD dwMinorVersion
    FIELD: DWORD dwBuildNumber
    FIELD: DWORD dwPlatformId
    FIELD: char[128] szCSDVersion
END-STRUCT
TYPEDEF: void* LPOSVERSIONINFO
