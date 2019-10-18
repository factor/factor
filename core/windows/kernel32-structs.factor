IN: win32-api
USING: alien kernel ;

C-STRUCT: OVERLAPPED
    { "int" "internal" }
    { "int" "internal-high" }
    { "int" "offset" }
    { "int" "offset-high" }
    { "void*" "event" } ;

C-STRUCT: SYSTEMTIME
    { "WORD" "wYear" }
    { "WORD" "wMonth" }
    { "WORD" "wDayOfWeek" }
    { "WORD" "wDay" }
    { "WORD" "wHour" }
    { "WORD" "wMinute" }
    { "WORD" "wSecond" }
    { "WORD" "wMilliseconds" } ;

C-STRUCT: TIME_ZONE_INFORMATION
    { "LONG" "Bias" }
    { { "WCHAR" 32 } "StandardName" }
    { "SYSTEMTIME" "StandardDate" }
    { "LONG" "StandardBias" }
    { { "WCHAR" 32 } "DaylightName" }
    { "SYSTEMTIME" "DaylightDate" }
    { "LONG" "DaylightBias" } ;

C-STRUCT: FILETIME
    { "DWORD" "dwLowDateTime" }
    { "DWORD" "dwHighDateTime" } ;

C-STRUCT: STARTUPINFO
    { "DWORD" "cb" }
    { "LPTSTR" "lpReserved" }
    { "LPTSTR" "lpDesktop" }
    { "LPTSTR" "lpTitle" }
    { "DWORD" "dwX" }
    { "DWORD" "dwY" }
    { "DWORD" "dwXSize" }
    { "DWORD" "dwYSize" }
    { "DWORD" "dwXCountChars" }
    { "DWORD" "dwYCountChars" }
    { "DWORD" "dwFillAttribute" }
    { "DWORD" "dwFlags" }
    { "WORD" "wShowWindow" }
    { "WORD" "cbReserved2" }
    { "LPBYTE" "lpReserved2" }
    { "HANDLE" "hStdInput" }
    { "HANDLE" "hStdOutput" }
    { "HANDLE" "hStdError" } ;

TYPEDEF: void* LPSTARTUPINFO

C-STRUCT: PROCESS_INFORMATION
    { "HANDLE" "hProcess" }
    { "HANDLE" "hThread" }
    { "DWORD" "dwProcessId" }
    { "DWORD" "dwThreadId" } ;

C-STRUCT: SYSTEM_INFO
    { "DWORD" "dwOemId" }
    { "DWORD" "dwPageSize" }
    { "LPVOID" "lpMinimumApplicationAddress" }
    { "LPVOID" "lpMaximumApplicationAddress" }
    { "DWORD_PTR" "dwActiveProcessorMask" }
    { "DWORD" "dwNumberOfProcessors" }
    { "DWORD" "dwProcessorType" }
    { "DWORD" "dwAllocationGranularity" }
    { "WORD" "wProcessorLevel" }
    { "WORD" "wProcessorRevision" } ;

TYPEDEF: void* LPSYSTEM_INFO

C-STRUCT: MEMORYSTATUS
    { "DWORD" "dwLength" }
    { "DWORD" "dwMemoryLoad" }
    { "SIZE_T" "dwTotalPhys" }
    { "SIZE_T" "dwAvailPhys" }
    { "SIZE_T" "dwTotalPageFile" }
    { "SIZE_T" "dwAvailPageFile" }
    { "SIZE_T" "dwTotalVirtual" }
    { "SIZE_T" "dwAvailVirtual" } ;

TYPEDEF: void* LPMEMORYSTATUS

C-STRUCT: MEMORYSTATUSEX
    { "DWORD" "dwLength" }
    { "DWORD" "dwMemoryLoad" }
    { "DWORDLONG" "ullTotalPhys" }
    { "DWORDLONG" "ullAvailPhys" }
    { "DWORDLONG" "ullTotalPageFile" }
    { "DWORDLONG" "ullAvailPageFile" }
    { "DWORDLONG" "ullTotalVirtual" }
    { "DWORDLONG" "ullAvailVirtual" }
    { "DWORDLONG" "ullAvailExtendedVirtual" } ;

TYPEDEF: void* LPMEMORYSTATUSEX

C-STRUCT: OSVERSIONINFO
    { "DWORD" "dwOSVersionInfoSize" }
    { "DWORD" "dwMajorVersion" }
    { "DWORD" "dwMinorVersion" }
    { "DWORD" "dwBuildNumber" }
    { "DWORD" "dwPlatformId" }
    { { "WCHAR" 128 } "szCSDVersion" } ;

TYPEDEF: void* LPOSVERSIONINFO

C-STRUCT: MEMORY_BASIC_INFORMATION
  { "void*" "BaseAddress" }
  { "void*" "AllocationBase" }
  { "DWORD" "AllocationProtect" }
  { "SIZE_T" "RegionSize" }
  { "DWORD" "state" }
  { "DWORD" "protect" }
  { "DWORD" "type" } ;


: SE_CREATE_TOKEN_NAME "SeCreateTokenPrivilege" ;
: SE_ASSIGNPRIMARYTOKEN_NAME "SeAssignPrimaryTokenPrivilege" ;
: SE_LOCK_MEMORY_NAME "SeLockMemoryPrivilege" ;
: SE_INCREASE_QUOTA_NAME "SeIncreaseQuotaPrivilege" ;
: SE_UNSOLICITED_INPUT_NAME "SeUnsolicitedInputPrivilege" ;
: SE_MACHINE_ACCOUNT_NAME "SeMachineAccountPrivilege" ;
: SE_TCB_NAME "SeTcbPrivilege" ;
: SE_SECURITY_NAME "SeSecurityPrivilege" ;
: SE_TAKE_OWNERSHIP_NAME "SeTakeOwnershipPrivilege" ;
: SE_LOAD_DRIVER_NAME "SeLoadDriverPrivilege" ;
: SE_SYSTEM_PROFILE_NAME "SeSystemProfilePrivilege" ;
: SE_SYSTEMTIME_NAME "SeSystemtimePrivilege" ;
: SE_PROF_SINGLE_PROCESS_NAME "SeProfileSingleProcessPrivilege" ;
: SE_INC_BASE_PRIORITY_NAME "SeIncreaseBasePriorityPrivilege" ;
: SE_CREATE_PAGEFILE_NAME "SeCreatePagefilePrivilege" ;
: SE_CREATE_PERMANENT_NAME "SeCreatePermanentPrivilege" ;
: SE_BACKUP_NAME "SeBackupPrivilege" ;
: SE_RESTORE_NAME "SeRestorePrivilege" ;
: SE_SHUTDOWN_NAME "SeShutdownPrivilege" ;
: SE_DEBUG_NAME "SeDebugPrivilege" ;
: SE_AUDIT_NAME "SeAuditPrivilege" ;
: SE_SYSTEM_ENVIRONMENT_NAME "SeSystemEnvironmentPrivilege" ;
: SE_CHANGE_NOTIFY_NAME "SeChangeNotifyPrivilege" ;
: SE_REMOTE_SHUTDOWN_NAME "SeRemoteShutdownPrivilege" ;
: SE_UNDOCK_NAME "SeUndockPrivilege" ;
: SE_ENABLE_DELEGATION_NAME "SeEnableDelegationPrivilege" ;
: SE_MANAGE_VOLUME_NAME "SeManageVolumePrivilege" ;
: SE_IMPERSONATE_NAME "SeImpersonatePrivilege" ;
: SE_CREATE_GLOBAL_NAME "SeCreateGlobalPrivilege" ;

: SE_GROUP_MANDATORY HEX: 00000001 ;
: SE_GROUP_ENABLED_BY_DEFAULT HEX: 00000002 ;
: SE_GROUP_ENABLED HEX: 00000004 ;
: SE_GROUP_OWNER HEX: 00000008 ;
: SE_GROUP_USE_FOR_DENY_ONLY HEX: 00000010 ;
: SE_GROUP_LOGON_ID HEX: C0000000 ;
: SE_GROUP_RESOURCE HEX: 20000000 ;

: SE_PRIVILEGE_ENABLED_BY_DEFAULT HEX: 00000001 ;
: SE_PRIVILEGE_ENABLED HEX: 00000002 ;
: SE_PRIVILEGE_REMOVE HEX: 00000004 ;
: SE_PRIVILEGE_USED_FOR_ACCESS HEX: 80000000 ;

: PRIVILEGE_SET_ALL_NECESSARY 1 ;

: SE_OWNER_DEFAULTED HEX: 00000001 ;
: SE_GROUP_DEFAULTED HEX: 00000002 ;
: SE_DACL_PRESENT HEX: 00000004 ;
: SE_DACL_DEFAULTED HEX: 00000008 ;
: SE_SACL_PRESENT HEX: 00000010 ;
: SE_SACL_DEFAULTED HEX: 00000020 ;
: SE_DACL_AUTO_INHERIT_REQ HEX: 00000100 ;
: SE_SACL_AUTO_INHERIT_REQ HEX: 00000200 ;
: SE_DACL_AUTO_INHERITED HEX: 00000400 ;
: SE_SACL_AUTO_INHERITED HEX: 00000800 ;
: SE_DACL_PROTECTED  HEX: 00001000 ;
: SE_SACL_PROTECTED  HEX: 00002000 ;
: SE_SELF_RELATIVE HEX: 00008000 ;

: ANYSIZE_ARRAY 1 ; inline

C-STRUCT: LUID
    { "DWORD" "LowPart" }
    { "LONG" "HighPart" } ;
TYPEDEF: LUID* PLUID

C-STRUCT: LUID_AND_ATTRIBUTES
    { "LUID" "Luid" }
    { "DWORD" "Attributes" } ;
TYPEDEF: LUID_AND_ATTRIBUTES* PLUID_AND_ATTRIBUTES

C-STRUCT: TOKEN_PRIVILEGES
    { "DWORD" "PrivilegeCount" }
    { "LUID_AND_ATTRIBUTES*" "Privileges" } ;
TYPEDEF: TOKEN_PRIVILEGES* PTOKEN_PRIVILEGES

C-STRUCT: WIN32_FILE_ATTRIBUTE_DATA
    { "DWORD" "dwFileAttributes" }
    { "FILETIME" "ftCreationTime" }
    { "FILETIME" "ftLastAccessTime" }
    { "FILETIME" "ftLastWriteTime" }
    { "DWORD" "nFileSizeHigh" }
    { "DWORD" "nFileSizeLow" } ;
TYPEDEF: WIN32_FILE_ATTRIBUTE_DATA* LPWIN32_FILE_ATTRIBUTE_DATA

C-STRUCT: BY_HANDLE_FILE_INFORMATION
  { "DWORD" "dwFileAttributes" }
  { "FILETIME" "ftCreationTime" }
  { "FILETIME" "ftLastAccessTime" }
  { "FILETIME" "ftLastWriteTime" }
  { "DWORD" "dwVolumeSerialNumber" }
  { "DWORD" "nFileSizeHigh" }
  { "DWORD" "nFileSizeLow" }
  { "DWORD" "nNumberOfLinks" }
  { "DWORD" "nFileIndexHigh" }
  { "DWORD" "nFileIndexLow" } ;
TYPEDEF: BY_HANDLE_FILE_INFORMATION* LPBY_HANDLE_FILE_INFORMATION

: OFS_MAXPATHNAME 128 ;

C-STRUCT: OFSTRUCT
    { "BYTE" "cBytes" }
    { "BYTE" "fFixedDisk" }
    { "WORD" "nErrCode" }
    { "WORD" "Reserved1" }
    { "WORD" "Reserved2" }
    ! { { "CHAR" OFS_MAXPATHNAME } "szPathName" } ;
    { { "CHAR" 128 } "szPathName" } ;

TYPEDEF: OFSTRUCT* LPOFSTRUCT

! MAX_PATH = 260
C-STRUCT: WIN32_FIND_DATA
    { "DWORD" "dwFileAttributes" }
    { "FILETIME" "ftCreationTime" }
    { "FILETIME" "ftLastAccessTime" }
    { "FILETIME" "ftLastWriteTime" }
    { "DWORD" "nFileSizeHigh" }
    { "DWORD" "nFileSizeLow" }
    { "DWORD" "dwReserved0" }
    { "DWORD" "dwReserved1" }
    ! { { "TCHAR" MAX_PATH } "cFileName" }
    { { "TCHAR" 260 } "cFileName" }
    { { "TCHAR" 14 } "cAlternateFileName" } ;

TYPEDEF: WIN32_FIND_DATA* PWIN32_FIND_DATA
TYPEDEF: WIN32_FIND_DATA* LPWIN32_FIND_DATA

