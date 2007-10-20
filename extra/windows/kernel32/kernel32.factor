! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax windows.types ;
IN: windows.kernel32

: MAX_PATH 260 ; inline

: GHND          HEX: 40 ; inline
: GMEM_FIXED          0 ; inline
: GMEM_MOVEABLE       2 ; inline
: GMEM_ZEROINIT HEX: 40 ; inline
: GPTR          HEX: 40 ; inline

: GENERIC_READ    HEX: 80000000 ; inline
: GENERIC_WRITE   HEX: 40000000 ; inline
: GENERIC_EXECUTE HEX: 20000000 ; inline
: GENERIC_ALL     HEX: 10000000 ; inline

: CREATE_NEW        1 ; inline
: CREATE_ALWAYS     2 ; inline
: OPEN_EXISTING     3 ; inline
: OPEN_ALWAYS       4 ; inline
: TRUNCATE_EXISTING 5 ; inline
              
: FILE_LIST_DIRECTORY       HEX: 00000001 ; inline
: FILE_READ_DAT             HEX: 00000001 ; inline
: FILE_ADD_FILE             HEX: 00000002 ; inline
: FILE_WRITE_DATA           HEX: 00000002 ; inline
: FILE_ADD_SUBDIRECTORY     HEX: 00000004 ; inline
: FILE_APPEND_DATA          HEX: 00000004 ; inline
: FILE_CREATE_PIPE_INSTANCE HEX: 00000004 ; inline
: FILE_READ_EA              HEX: 00000008 ; inline
: FILE_READ_PROPERTIES      HEX: 00000008 ; inline
: FILE_WRITE_EA             HEX: 00000010 ; inline
: FILE_WRITE_PROPERTIES     HEX: 00000010 ; inline
: FILE_EXECUTE              HEX: 00000020 ; inline
: FILE_TRAVERSE             HEX: 00000020 ; inline
: FILE_DELETE_CHILD         HEX: 00000040 ; inline
: FILE_READ_ATTRIBUTES      HEX: 00000080 ; inline
: FILE_WRITE_ATTRIBUTES     HEX: 00000100 ; inline

: FILE_SHARE_READ        1 ; inline
: FILE_SHARE_WRITE       2 ; inline
: FILE_SHARE_DELETE      4 ; inline
: FILE_SHARE_VALID_FLAGS 7 ; inline

: FILE_FLAG_WRITE_THROUGH       HEX: 80000000 ; inline
: FILE_FLAG_OVERLAPPED          HEX: 40000000 ; inline
: FILE_FLAG_NO_BUFFERING        HEX: 20000000 ; inline
: FILE_FLAG_RANDOM_ACCESS       HEX: 10000000 ; inline
: FILE_FLAG_SEQUENTIAL_SCAN     HEX: 08000000 ; inline
: FILE_FLAG_DELETE_ON_CLOSE     HEX: 04000000 ; inline
: FILE_FLAG_BACKUP_SEMANTICS    HEX: 02000000 ; inline
: FILE_FLAG_POSIX_SEMANTICS     HEX: 01000000 ; inline
: FILE_FLAG_OPEN_REPARSE_POINT  HEX: 00200000 ; inline
: FILE_FLAG_OPEN_NO_RECALL      HEX: 00100000 ; inline
: FILE_FLAG_FIRST_PIPE_INSTANCE HEX: 00080000 ; inline

: FILE_ATTRIBUTE_READONLY            HEX: 00000001 ; inline
: FILE_ATTRIBUTE_HIDDEN              HEX: 00000002 ; inline
: FILE_ATTRIBUTE_SYSTEM              HEX: 00000004 ; inline
: FILE_ATTRIBUTE_DIRECTORY           HEX: 00000010 ; inline
: FILE_ATTRIBUTE_ARCHIVE             HEX: 00000020 ; inline
: FILE_ATTRIBUTE_DEVICE              HEX: 00000040 ; inline
: FILE_ATTRIBUTE_NORMAL              HEX: 00000080 ; inline
: FILE_ATTRIBUTE_TEMPORARY           HEX: 00000100 ; inline
: FILE_ATTRIBUTE_SPARSE_FILE         HEX: 00000200 ; inline
: FILE_ATTRIBUTE_REPARSE_POINT       HEX: 00000400 ; inline
: FILE_ATTRIBUTE_COMPRESSED          HEX: 00000800 ; inline
: FILE_ATTRIBUTE_OFFLINE             HEX: 00001000 ; inline
: FILE_ATTRIBUTE_NOT_CONTENT_INDEXED HEX: 00002000 ; inline
: FILE_ATTRIBUTE_ENCRYPTED           HEX: 00004000 ; inline

: FILE_NOTIFY_CHANGE_FILE        HEX: 001 ; inline
: FILE_NOTIFY_CHANGE_DIR_NAME    HEX: 002 ; inline
: FILE_NOTIFY_CHANGE_ATTRIBUTES  HEX: 004 ; inline
: FILE_NOTIFY_CHANGE_SIZE        HEX: 008 ; inline
: FILE_NOTIFY_CHANGE_LAST_WRITE  HEX: 010 ; inline
: FILE_NOTIFY_CHANGE_LAST_ACCESS HEX: 020 ; inline
: FILE_NOTIFY_CHANGE_CREATION    HEX: 040 ; inline
: FILE_NOTIFY_CHANGE_EA          HEX: 080 ; inline
: FILE_NOTIFY_CHANGE_SECURITY    HEX: 100 ; inline
: FILE_NOTIFY_CHANGE_FILE_NAME   HEX: 200 ; inline
: FILE_NOTIFY_CHANGE_ALL         HEX: 3ff ; inline

C-STRUCT: FILE_NOTIFY_INFORMATION
    { "DWORD" "NextEntryOffset" }
    { "DWORD" "Action" }
    { "DWORD" "FileNameLength" }
    { "WCHAR*" "FileName" } ;
TYPEDEF: FILE_NOTIFY_INFORMATION* PFILE_NOTIFY_INFORMATION

: STD_INPUT_HANDLE  -10 ; inline
: STD_OUTPUT_HANDLE -11 ; inline
: STD_ERROR_HANDLE  -12 ; inline

: INVALID_HANDLE_VALUE -1 <alien> ; inline
: INVALID_FILE_SIZE HEX: FFFFFFFF ; inline

: FILE_BEGIN 0 ; inline
: FILE_CURRENT 1 ; inline
: FILE_END 2 ; inline

: OF_READ 0 ;
: OF_READWRITE    2 ;
: OF_WRITE    1 ;
: OF_SHARE_COMPAT    0 ;
: OF_SHARE_DENY_NONE    64 ;
: OF_SHARE_DENY_READ    48 ;
: OF_SHARE_DENY_WRITE    32 ;
: OF_SHARE_EXCLUSIVE    16 ;
: OF_CANCEL    2048 ;
: OF_CREATE    4096 ;
: OF_DELETE    512 ;
: OF_EXIST    16384 ;
: OF_PARSE    256 ;
: OF_PROMPT    8192 ;
: OF_REOPEN    32768 ;
: OF_VERIFY    1024 ;


: INFINITE HEX: FFFFFFFF ; inline

! From C:\cygwin\usr\include\w32api\winbase.h
: FILE_TYPE_UNKNOWN 0 ;
: FILE_TYPE_DISK 1 ;
: FILE_TYPE_CHAR 2 ;
: FILE_TYPE_PIPE 3 ;
: FILE_TYPE_REMOTE HEX: 8000 ;

: TIME_ZONE_ID_UNKNOWN 0 ; inline
: TIME_ZONE_ID_STANDARD 1 ; inline
: TIME_ZONE_ID_DAYLIGHT 2 ; inline
: TIME_ZONE_ID_INVALID HEX: FFFFFFFF ; inline


: CREATE_DEFAULT_ERROR_MODE HEX: 4000000 ; inline
: DETACHED_PROCESS 8 ; inline
: PF_XMMI64_INSTRUCTIONS_AVAILABLE 10 ; inline
: PF_SSE3_INSTRUCTIONS_AVAILABLE 13 ; inline

: MAX_COMPUTERNAME_LENGTH 15 ; inline
: UNLEN 256 ; inline

: PROCESS_TERMINATE ( -- n ) HEX: 1 ; inline
: PROCESS_CREATE_THREAD ( -- n ) HEX: 2 ; inline
: PROCESS_VM_OPERATION ( -- n ) HEX: 8 ; inline
: PROCESS_VM_READ ( -- n ) HEX: 10 ; inline
: PROCESS_VM_WRITE ( -- n ) HEX: 20 ; inline
: PROCESS_DUP_HANDLE ( -- n ) HEX: 40 ; inline
: PROCESS_CREATE_PROCESS ( -- n ) HEX: 80 ; inline
: PROCESS_SET_QUOTA ( -- n ) HEX: 100 ; inline
: PROCESS_SET_INFORMATION ( -- n ) HEX: 200 ; inline
: PROCESS_QUERY_INFORMATION ( -- n ) HEX: 400 ; inline

: MEM_COMMIT ( -- n ) HEX: 1000 ; inline
: MEM_RELEASE ( -- n ) HEX: 8000 ; inline

: PAGE_NOACCESS    1 ; inline
: PAGE_READONLY    2 ; inline
: PAGE_READWRITE 4 ; inline
: PAGE_WRITECOPY 8 ; inline
: PAGE_EXECUTE HEX: 10 ; inline
: PAGE_EXECUTE_READ HEX: 20 ; inline
: PAGE_EXECUTE_READWRITE HEX: 40 ; inline
: PAGE_EXECUTE_WRITECOPY HEX: 80 ; inline
: PAGE_GUARD HEX: 100 ; inline
: PAGE_NOCACHE HEX: 200 ; inline

: SEC_BASED HEX: 00200000 ; inline
: SEC_NO_CHANGE HEX: 00400000 ; inline
: SEC_FILE HEX: 00800000 ; inline
: SEC_IMAGE HEX: 01000000 ; inline
: SEC_VLM HEX: 02000000 ; inline
: SEC_RESERVE HEX: 04000000 ; inline
: SEC_COMMIT HEX: 08000000 ; inline
: SEC_NOCACHE HEX: 10000000 ; inline
: MEM_IMAGE SEC_IMAGE ; inline

: ERROR_ALREADY_EXISTS 183 ; inline

: FILE_MAP_ALL_ACCESS HEX: f001f ;
: FILE_MAP_READ   4 ;
: FILE_MAP_WRITE  2 ;
: FILE_MAP_COPY   1 ;

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

C-STRUCT: GUID
    { "ulong" "Data1" }
    { "ushort" "Data2" }
    { "ushort" "Data3" }
    { { "uchar" 8 } "Data4" } ;


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

: MAXIMUM_WAIT_OBJECTS 64 ; inline
: MAXIMUM_SUSPEND_COUNT HEX: 7f ; inline
: WAIT_OBJECT_0 0 ; inline
: WAIT_ABANDONED_0 128 ; inline
: WAIT_TIMEOUT 258 ; inline
: WAIT_IO_COMPLETION HEX: c0 ; inline
: WAIT_FAILED HEX: ffffffff ; inline

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
TYPEDEF: void* POVERLAPPED
TYPEDEF: void* LPOVERLAPPED
TYPEDEF: void* LPSECURITY_ATTRIBUTES
TYPEDEF: void* LPPROCESS_INFORMATION

TYPEDEF: SYSTEMTIME* PSYSTEMTIME
TYPEDEF: PSYSTEMTIME LPSYSTEMTIME

TYPEDEF: TIME_ZONE_INFORMATION* PTIME_ZONE_INFORMATION
TYPEDEF: PTIME_ZONE_INFORMATION LPTIME_ZONE_INFORMATION

TYPEDEF: FILETIME* PFILETIME
TYPEDEF: PFILETIME LPFILETIME

TYPEDEF: int GET_FILEEX_INFO_LEVELS

C-STRUCT: SECURITY_ATTRIBUTES
    { "DWORD" "nLength" }
    { "LPVOID" "lpSecurityDescriptor" }
    { "BOOL" "bInheritHandle" } ;

: HANDLE_FLAG_INHERIT 1 ; inline
: HANDLE_FLAG_PROTECT_FROM_CLOSE 2 ; inline

: STARTF_USESHOWWINDOW    HEX: 00000001 ; inline
: STARTF_USESIZE          HEX: 00000002 ; inline
: STARTF_USEPOSITION      HEX: 00000004 ; inline
: STARTF_USECOUNTCHARS    HEX: 00000008 ; inline
: STARTF_USEFILLATTRIBUTE HEX: 00000010 ; inline
: STARTF_RUNFULLSCREEN    HEX: 00000020 ; inline
: STARTF_FORCEONFEEDBACK  HEX: 00000040 ; inline
: STARTF_FORCEOFFFEEDBACK HEX: 00000080 ; inline
: STARTF_USESTDHANDLES    HEX: 00000100 ; inline
: STARTF_USEHOTKEY        HEX: 00000200 ; inline

: PIPE_ACCESS_INBOUND  1 ; inline
: PIPE_ACCESS_OUTBOUND 2 ; inline
: PIPE_ACCESS_DUPLEX   3 ; inline

: PIPE_TYPE_BYTE    0 ; inline
: PIPE_TYPE_MESSAGE 4 ; inline

: PIPE_READMODE_BYTE    0 ; inline
: PIPE_READMODE_MESSAGE 2 ; inline

: PIPE_WAIT   0 ; inline
: PIPE_NOWAIT 1 ; inline

: PIPE_UNLIMITED_INSTANCES 255 ; inline

LIBRARY: kernel32
! FUNCTION: _hread
! FUNCTION: _hwrite
! FUNCTION: _lclose
! FUNCTION: _lcreat
! FUNCTION: _llseek
! FUNCTION: _lopen
! FUNCTION: _lread
! FUNCTION: _lwrite
! FUNCTION: ActivateActCtx
! FUNCTION: AddAtomA
! FUNCTION: AddAtomW
! FUNCTION: AddConsoleAliasA
! FUNCTION: AddConsoleAliasW
! FUNCTION: AddLocalAlternateComputerNameA
! FUNCTION: AddLocalAlternateComputerNameW
! FUNCTION: AddRefActCtx
! FUNCTION: AddVectoredExceptionHandler
! FUNCTION: AllocateUserPhysicalPages
! FUNCTION: AllocConsole
! FUNCTION: AreFileApisANSI
! FUNCTION: AssignProcessToJobObject
! FUNCTION: AttachConsole
! FUNCTION: BackupRead
! FUNCTION: BackupSeek
! FUNCTION: BackupWrite
! FUNCTION: BaseCheckAppcompatCache
! FUNCTION: BaseCleanupAppcompatCache
! FUNCTION: BaseCleanupAppcompatCacheSupport
! FUNCTION: BaseDumpAppcompatCache
! FUNCTION: BaseFlushAppcompatCache
! FUNCTION: BaseInitAppcompatCache
! FUNCTION: BaseInitAppcompatCacheSupport
! FUNCTION: BasepCheckWinSaferRestrictions
! FUNCTION: BaseProcessInitPostImport
! FUNCTION: BaseQueryModuleData
! FUNCTION: BaseUpdateAppcompatCache
! FUNCTION: Beep
! FUNCTION: BeginUpdateResourceA
! FUNCTION: BeginUpdateResourceW
! FUNCTION: BindIoCompletionCallback
! FUNCTION: BuildCommDCBA
! FUNCTION: BuildCommDCBAndTimeoutsA
! FUNCTION: BuildCommDCBAndTimeoutsW
! FUNCTION: BuildCommDCBW
! FUNCTION: CallNamedPipeA
! FUNCTION: CallNamedPipeW
! FUNCTION: CancelDeviceWakeupRequest
FUNCTION: BOOL CancelIo ( HANDLE h ) ;
! FUNCTION: CancelTimerQueueTimer
! FUNCTION: CancelWaitableTimer
! FUNCTION: ChangeTimerQueueTimer
! FUNCTION: CheckNameLegalDOS8Dot3A
! FUNCTION: CheckNameLegalDOS8Dot3W
! FUNCTION: CheckRemoteDebuggerPresent
! FUNCTION: ClearCommBreak
! FUNCTION: ClearCommError
! FUNCTION: CloseConsoleHandle
FUNCTION: BOOL CloseHandle ( HANDLE h ) ;
! FUNCTION: CloseProfileUserMapping
! FUNCTION: CmdBatNotification
! FUNCTION: CommConfigDialogA
! FUNCTION: CommConfigDialogW
! FUNCTION: CompareFileTime
! FUNCTION: CompareStringA
! FUNCTION: CompareStringW
FUNCTION: BOOL ConnectNamedPipe ( HANDLE hNamedPipe, LPOVERLAPPED lpOverlapped ) ;
! FUNCTION: ConsoleMenuControl
! FUNCTION: ContinueDebugEvent
! FUNCTION: ConvertDefaultLocale
! FUNCTION: ConvertFiberToThread
! FUNCTION: ConvertThreadToFiber
! FUNCTION: CopyFileA
! FUNCTION: CopyFileExA
! FUNCTION: CopyFileExW
! FUNCTION: CopyFileW
! FUNCTION: CopyLZFile
! FUNCTION: CreateActCtxA
! FUNCTION: CreateActCtxW
! FUNCTION: CreateConsoleScreenBuffer
! FUNCTION: CreateDirectoryA
! FUNCTION: CreateDirectoryExA
! FUNCTION: CreateDirectoryExW
FUNCTION: BOOL CreateDirectoryW ( LPCTSTR lpPathName, LPSECURITY_ATTRIBUTES lpSecurityAttribytes ) ;
: CreateDirectory CreateDirectoryW ;

! FUNCTION: CreateEventA
! FUNCTION: CreateEventW
! FUNCTION: CreateFiber
! FUNCTION: CreateFiberEx


FUNCTION: HANDLE CreateFileW ( LPCTSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, LPSECURITY_ATTRIBUTES lpSecurityAttribures, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile ) ;
: CreateFile CreateFileW ; inline

FUNCTION: HANDLE  CreateFileMappingW ( HANDLE hFile,
                                       LPSECURITY_ATTRIBUTES lpAttributes,
                                       DWORD flProtect,
                                       DWORD dwMaximumSizeHigh,
                                       DWORD dwMaximumSizeLow,
                                       LPCTSTR lpName ) ;
: CreateFileMapping CreateFileMappingW ;

! FUNCTION: CreateHardLinkA
! FUNCTION: CreateHardLinkW
! FUNCTION: HANDLE CreateIoCompletionPort ( HANDLE hFileHandle, HANDLE hExistingCompletionPort, ULONG_PTR uCompletionKey, DWORD dwNumberofConcurrentThreads ) ;
FUNCTION: HANDLE CreateIoCompletionPort ( HANDLE hFileHandle, HANDLE hExistingCompletionPort, void* uCompletionKey, DWORD dwNumberofConcurrentThreads ) ;
! FUNCTION: CreateJobObjectA
! FUNCTION: CreateJobObjectW
! FUNCTION: CreateJobSet
! FUNCTION: CreateMailslotA
! FUNCTION: CreateMailslotW
! FUNCTION: CreateMemoryResourceNotification
! FUNCTION: CreateMutexA
! FUNCTION: CreateMutexW
! FUNCTION: CreateNamedPipeA
FUNCTION: HANDLE CreateNamedPipeW ( LPCTSTR lpName, DWORD dwOpenMode, DWORD dwPipeMode, DWORD nMaxInstances, DWORD nOutBufferSize, DWORD nInBufferSize, DWORD nDefaultTimeOut, LPSECURITY_ATTRIBUTES lpSecurityAttributes ) ;
: CreateNamedPipe CreateNamedPipeW ;

! FUNCTION: CreateNlsSecurityDescriptor
FUNCTION: BOOL CreatePipe ( PHANDLE hReadPipe, PHANDLE hWritePipe, LPSECURITY_ATTRIBUTES lpPipeAttributes, DWORD nSize ) ;
FUNCTION: BOOL CreateProcessW ( LPCTSTR lpApplicationname,
                                LPTSTR lpCommandLine,
                                LPSECURITY_ATTRIBUTES lpProcessAttributes,
                                LPSECURITY_ATTRIBUTES lpThreadAttributes,
                                BOOL bInheritHandles,
                                DWORD dwCreationFlags,
                                LPVOID lpEnvironment,
                                LPCTSTR lpCurrentDirectory,
                                LPSTARTUPINFO lpStartupInfo,
                                LPPROCESS_INFORMATION lpProcessInformation ) ;
: CreateProcess CreateProcessW ;
! FUNCTION: CreateProcessInternalA
! FUNCTION: CreateProcessInternalW
! FUNCTION: CreateProcessInternalWSecure
FUNCTION: HANDLE CreateRemoteThread ( HANDLE hProcess,
                                      LPSECURITY_ATTRIBUTES lpThreadAttributes,
                                      SIZE_T dwStackSize,
                                      LPVOID lpStartAddress,
                                      LPVOID lpParameter,
                                      DWORD dwCreationFlags,
                                      LPDWORD lpThreadId ) ; 
! FUNCTION: CreateSemaphoreA
! FUNCTION: CreateSemaphoreW
! FUNCTION: CreateSocketHandle
! FUNCTION: CreateTapePartition
! FUNCTION: CreateThread
! FUNCTION: CreateTimerQueue
! FUNCTION: CreateTimerQueueTimer
! FUNCTION: CreateToolhelp32Snapshot
! FUNCTION: CreateVirtualBuffer
! FUNCTION: CreateWaitableTimerA
! FUNCTION: CreateWaitableTimerW
! FUNCTION: DeactivateActCtx
! FUNCTION: DebugActiveProcess
! FUNCTION: DebugActiveProcessStop
! FUNCTION: DebugBreak
! FUNCTION: DebugBreakProcess
! FUNCTION: DebugSetProcessKillOnExit
! FUNCTION: DecodePointer
! FUNCTION: DecodeSystemPointer
! FUNCTION: DefineDosDeviceA
! FUNCTION: DefineDosDeviceW
! FUNCTION: DelayLoadFailureHook
! FUNCTION: DeleteAtom
! FUNCTION: DeleteCriticalSection
! FUNCTION: DeleteFiber
! FUNCTION: DeleteFileA
FUNCTION: BOOL DeleteFileW ( LPCTSTR lpFileName ) ;
: DeleteFile DeleteFileW ;
! FUNCTION: DeleteTimerQueue
! FUNCTION: DeleteTimerQueueEx
! FUNCTION: DeleteTimerQueueTimer
! FUNCTION: DeleteVolumeMountPointA
! FUNCTION: DeleteVolumeMountPointW
! FUNCTION: DeviceIoControl
! FUNCTION: DisableThreadLibraryCalls
! FUNCTION: DisconnectNamedPipe
! FUNCTION: DnsHostnameToComputerNameA
! FUNCTION: DnsHostnameToComputerNameW
! FUNCTION: DosDateTimeToFileTime
! FUNCTION: DosPathToSessionPathA
! FUNCTION: DosPathToSessionPathW
! FUNCTION: DuplicateConsoleHandle
! FUNCTION: DuplicateHandle
! FUNCTION: EncodePointer
! FUNCTION: EncodeSystemPointer
! FUNCTION: EndUpdateResourceA
! FUNCTION: EndUpdateResourceW
! FUNCTION: EnterCriticalSection
! FUNCTION: EnumCalendarInfoA
! FUNCTION: EnumCalendarInfoExA
! FUNCTION: EnumCalendarInfoExW
! FUNCTION: EnumCalendarInfoW
! FUNCTION: EnumDateFormatsA
! FUNCTION: EnumDateFormatsExA
! FUNCTION: EnumDateFormatsExW
! FUNCTION: EnumDateFormatsW
! FUNCTION: EnumerateLocalComputerNamesA
! FUNCTION: EnumerateLocalComputerNamesW
! FUNCTION: EnumLanguageGroupLocalesA
! FUNCTION: EnumLanguageGroupLocalesW
! FUNCTION: EnumResourceLanguagesA
! FUNCTION: EnumResourceLanguagesW
! FUNCTION: EnumResourceNamesA
! FUNCTION: EnumResourceNamesW
! FUNCTION: EnumResourceTypesA
! FUNCTION: EnumResourceTypesW
! FUNCTION: EnumSystemCodePagesA
! FUNCTION: EnumSystemCodePagesW
! FUNCTION: EnumSystemGeoID
! FUNCTION: EnumSystemLanguageGroupsA
! FUNCTION: EnumSystemLanguageGroupsW
! FUNCTION: EnumSystemLocalesA
! FUNCTION: EnumSystemLocalesW
! FUNCTION: EnumTimeFormatsA
! FUNCTION: EnumTimeFormatsW
! FUNCTION: EnumUILanguagesA
! FUNCTION: EnumUILanguagesW
! FUNCTION: EraseTape
! FUNCTION: EscapeCommFunction
! FUNCTION: ExitProcess
! FUNCTION: ExitThread
! FUNCTION: ExitVDM
! FUNCTION: ExpandEnvironmentStringsA
! FUNCTION: ExpandEnvironmentStringsW
! FUNCTION: ExpungeConsoleCommandHistoryA
! FUNCTION: ExpungeConsoleCommandHistoryW
! FUNCTION: ExtendVirtualBuffer
! FUNCTION: FatalAppExitA
! FUNCTION: FatalAppExitW
! FUNCTION: FatalExit
! FUNCTION: FileTimeToDosDateTime
! FUNCTION: FileTimeToLocalFileTime
! FUNCTION: FileTimeToSystemTime
! FUNCTION: FillConsoleOutputAttribute
! FUNCTION: FillConsoleOutputCharacterA
! FUNCTION: FillConsoleOutputCharacterW
! FUNCTION: FindActCtxSectionGuid
! FUNCTION: FindActCtxSectionStringA
! FUNCTION: FindActCtxSectionStringW
! FUNCTION: FindAtomA
! FUNCTION: FindAtomW
FUNCTION: BOOL FindClose ( HANDLE hFindFile ) ;
FUNCTION: BOOL FindCloseChangeNotification ( HANDLE hChangeHandle ) ;
FUNCTION: HANDLE FindFirstChangeNotificationW ( LPCTSTR lpPathName,
                                        BOOL bWatchSubtree,
                                        DWORD dwNotifyFilter ) ;
: FindFirstChangeNotification FindFirstChangeNotificationW ;
! FUNCTION: FindFirstFileA
! FUNCTION: FindFirstFileExA
! FUNCTION: FindFirstFileExW
FUNCTION: HANDLE FindFirstFileW ( LPCTSTR lpFileName, LPWIN32_FIND_DATA lpFindFileData ) ;
: FindFirstFile FindFirstFileW ;
! FUNCTION: FindFirstVolumeA
! FUNCTION: FindFirstVolumeMountPointA
! FUNCTION: FindFirstVolumeMountPointW
! FUNCTION: FindFirstVolumeW
FUNCTION: BOOL FindNextChangeNotification ( HANDLE hChangeHandle ) ;
! FUNCTION: FindNextFileA
FUNCTION: BOOL FindNextFileW ( HANDLE hFindFile, LPWIN32_FIND_DATA lpFindFileData ) ;
: FindNextFile FindNextFileW ;
! FUNCTION: FindNextVolumeA
! FUNCTION: FindNextVolumeMountPointA
! FUNCTION: FindNextVolumeMountPointW
! FUNCTION: FindNextVolumeW
! FUNCTION: FindResourceA
! FUNCTION: FindResourceExA
! FUNCTION: FindResourceExW
! FUNCTION: FindResourceW
! FUNCTION: FindVolumeClose
! FUNCTION: FindVolumeMountPointClose
! FUNCTION: FlushConsoleInputBuffer
! FUNCTION: FlushFileBuffers
! FUNCTION: FlushInstructionCache
! FUNCTION: FlushViewOfFile
! FUNCTION: FoldStringA
! FUNCTION: FoldStringW
! FUNCTION: FormatMessageA
! FUNCTION: FormatMessageW
! FUNCTION: FreeConsole
! FUNCTION: FreeEnvironmentStringsA
! FUNCTION: FreeEnvironmentStringsW
! FUNCTION: FreeLibrary
! FUNCTION: FreeLibraryAndExitThread
! FUNCTION: FreeResource
! FUNCTION: FreeUserPhysicalPages
! FUNCTION: FreeVirtualBuffer
! FUNCTION: GenerateConsoleCtrlEvent
! FUNCTION: GetACP
! FUNCTION: GetAtomNameA
! FUNCTION: GetAtomNameW
! FUNCTION: GetBinaryType
! FUNCTION: GetBinaryTypeA
! FUNCTION: GetBinaryTypeW
! FUNCTION: GetCalendarInfoA
! FUNCTION: GetCalendarInfoW
! FUNCTION: GetCommandLineA
! FUNCTION: GetCommandLineW
! FUNCTION: GetCommConfig
! FUNCTION: GetCommMask
! FUNCTION: GetCommModemStatus
! FUNCTION: GetCommProperties
! FUNCTION: GetCommState
! FUNCTION: GetCommTimeouts
! FUNCTION: GetComPlusPackageInstallStatus
! FUNCTION: GetCompressedFileSizeA
! FUNCTION: GetCompressedFileSizeW
FUNCTION: BOOL GetComputerNameW ( LPTSTR lpBuffer, LPDWORD lpnSize ) ;
! FUNCTION: GetComputerNameExW
! FUNCTION: GetComputerNameW
: GetComputerName GetComputerNameW ;
! FUNCTION: GetConsoleAliasA
! FUNCTION: GetConsoleAliasesA
! FUNCTION: GetConsoleAliasesLengthA
! FUNCTION: GetConsoleAliasesLengthW
! FUNCTION: GetConsoleAliasesW
! FUNCTION: GetConsoleAliasExesA
! FUNCTION: GetConsoleAliasExesLengthA
! FUNCTION: GetConsoleAliasExesLengthW
! FUNCTION: GetConsoleAliasExesW
! FUNCTION: GetConsoleAliasW
! FUNCTION: GetConsoleCharType
! FUNCTION: GetConsoleCommandHistoryA
! FUNCTION: GetConsoleCommandHistoryLengthA
! FUNCTION: GetConsoleCommandHistoryLengthW
! FUNCTION: GetConsoleCommandHistoryW
! FUNCTION: GetConsoleCP
! FUNCTION: GetConsoleCursorInfo
! FUNCTION: GetConsoleCursorMode
! FUNCTION: GetConsoleDisplayMode
! FUNCTION: GetConsoleFontInfo
! FUNCTION: GetConsoleFontSize
! FUNCTION: GetConsoleHardwareState
! FUNCTION: GetConsoleInputExeNameA
! FUNCTION: GetConsoleInputExeNameW
! FUNCTION: GetConsoleInputWaitHandle
! FUNCTION: GetConsoleKeyboardLayoutNameA
! FUNCTION: GetConsoleKeyboardLayoutNameW
! FUNCTION: GetConsoleMode
! FUNCTION: GetConsoleNlsMode
! FUNCTION: GetConsoleOutputCP
! FUNCTION: GetConsoleProcessList
! FUNCTION: GetConsoleScreenBufferInfo
! FUNCTION: GetConsoleSelectionInfo
FUNCTION: DWORD GetConsoleTitleW ( LPWSTR lpConsoleTitle, DWORD nSize ) ;
: GetConsoleTitle GetConsoleTitleW ; inline
! FUNCTION: GetConsoleWindow
! FUNCTION: GetCPFileNameFromRegistry
! FUNCTION: GetCPInfo
! FUNCTION: GetCPInfoExA
! FUNCTION: GetCPInfoExW
! FUNCTION: GetCurrencyFormatA
! FUNCTION: GetCurrencyFormatW
! FUNCTION: GetCurrentActCtx
! FUNCTION: GetCurrentConsoleFont
! FUNCTION: GetCurrentDirectoryA
! FUNCTION: GetCurrentDirectoryW
FUNCTION: HANDLE GetCurrentProcess ( ) ;
! FUNCTION: GetCurrentProcessId
FUNCTION: HANDLE GetCurrentThread ( ) ;
! FUNCTION: GetCurrentThreadId
! FUNCTION: GetDateFormatA
! FUNCTION: GetDateFormatW
! FUNCTION: GetDefaultCommConfigA
! FUNCTION: GetDefaultCommConfigW
! FUNCTION: GetDefaultSortkeySize
! FUNCTION: GetDevicePowerState
! FUNCTION: GetDiskFreeSpaceA
! FUNCTION: GetDiskFreeSpaceExA
! FUNCTION: GetDiskFreeSpaceExW
! FUNCTION: GetDiskFreeSpaceW
! FUNCTION: GetDllDirectoryA
! FUNCTION: GetDllDirectoryW
! FUNCTION: GetDriveTypeA
! FUNCTION: GetDriveTypeW
! FUNCTION: GetEnvironmentStrings
! FUNCTION: GetEnvironmentStringsA
! FUNCTION: GetEnvironmentStringsW
! FUNCTION: GetEnvironmentVariableA
! FUNCTION: GetEnvironmentVariableW
! FUNCTION: GetExitCodeProcess
! FUNCTION: GetExitCodeThread
! FUNCTION: GetExpandedNameA
! FUNCTION: GetExpandedNameW
! FUNCTION: GetFileAttributesA
FUNCTION: DWORD GetFileAttributesW ( LPCTSTR lpFileName ) ;
! FUNCTION: GetFileAttributesExA

: GetFileExInfoStandard 0 ; inline


FUNCTION: BOOL GetFileAttributesExW ( LPCTSTR lpFileName, GET_FILEEX_INFO_LEVELS fInfoLevelId, LPVOID lpFileInformation ) ;

: GetFileAttributesEx GetFileAttributesExW ;

FUNCTION: BOOL GetFileInformationByHandle ( HANDLE hFile, LPBY_HANDLE_FILE_INFORMATION lpFileInformation ) ;
FUNCTION: DWORD GetFileSize ( HANDLE hFile, LPDWORD lpFileSizeHigh ) ;
! FUNCTION: GetFileSizeEx
FUNCTION: BOOL GetFileTime ( HANDLE hFile, LPFILETIME lpCreationTime, LPFILETIME lpLastAccessTime, LPFILETIME lpLastWriteTime ) ;
FUNCTION: DWORD GetFileType ( HANDLE hFile ) ;
! FUNCTION: GetFirmwareEnvironmentVariableA
! FUNCTION: GetFirmwareEnvironmentVariableW
! FUNCTION: GetFullPathNameA
FUNCTION: DWORD GetFullPathNameW ( LPCTSTR lpFileName, DWORD nBufferLength, LPTSTR lpBuffer, LPTSTR* lpFilePart ) ;
: GetFullPathName GetFullPathNameW ;

!  clear "license.txt" 32768 "char[32768]" <c-object> f over >r GetFullPathName r> swap 2 * head >string .

! FUNCTION: GetGeoInfoA
! FUNCTION: GetGeoInfoW
! FUNCTION: GetHandleContext
FUNCTION: BOOL GetHandleInformation ( HANDLE hObject, LPDWORD lpdwFlags ) ;
! FUNCTION: GetLargestConsoleWindowSize
FUNCTION: DWORD GetLastError ( ) ;
! FUNCTION: GetLinguistLangSize
! FUNCTION: GetLocaleInfoA
! FUNCTION: GetLocaleInfoW
! FUNCTION: GetLocalTime
! FUNCTION: GetLogicalDrives
! FUNCTION: GetLogicalDriveStringsA
! FUNCTION: GetLogicalDriveStringsW
! FUNCTION: GetLongPathNameA
! FUNCTION: GetLongPathNameW
! FUNCTION: GetMailslotInfo
! FUNCTION: GetModuleFileNameA
! FUNCTION: GetModuleFileNameW
FUNCTION: HMODULE GetModuleHandleW ( LPCWSTR lpModuleName ) ;
: GetModuleHandle GetModuleHandleW ; inline
! FUNCTION: GetModuleHandleExA
! FUNCTION: GetModuleHandleExW
! FUNCTION: GetNamedPipeHandleStateA
! FUNCTION: GetNamedPipeHandleStateW
! FUNCTION: GetNamedPipeInfo
! FUNCTION: GetNativeSystemInfo
! FUNCTION: GetNextVDMCommand
! FUNCTION: GetNlsSectionName
! FUNCTION: GetNumaAvailableMemory
! FUNCTION: GetNumaAvailableMemoryNode
! FUNCTION: GetNumaHighestNodeNumber
! FUNCTION: GetNumaNodeProcessorMask
! FUNCTION: GetNumaProcessorMap
! FUNCTION: GetNumaProcessorNode
! FUNCTION: GetNumberFormatA
! FUNCTION: GetNumberFormatW
! FUNCTION: GetNumberOfConsoleFonts
! FUNCTION: GetNumberOfConsoleInputEvents
! FUNCTION: GetNumberOfConsoleMouseButtons
! FUNCTION: GetOEMCP
FUNCTION: BOOL GetOverlappedResult ( HANDLE hFile, LPOVERLAPPED lpOverlapped, LPDWORD lpNumberOfBytesTransferred, BOOL bWait ) ;
! FUNCTION: GetPriorityClass
! FUNCTION: GetPrivateProfileIntA
! FUNCTION: GetPrivateProfileIntW
! FUNCTION: GetPrivateProfileSectionA
! FUNCTION: GetPrivateProfileSectionNamesA
! FUNCTION: GetPrivateProfileSectionNamesW
! FUNCTION: GetPrivateProfileSectionW
! FUNCTION: GetPrivateProfileStringA
! FUNCTION: GetPrivateProfileStringW
! FUNCTION: GetPrivateProfileStructA
! FUNCTION: GetPrivateProfileStructW
FUNCTION: LPVOID GetProcAddress ( HMODULE hModule, char* lpProcName ) ;
! FUNCTION: GetProcessAffinityMask
! FUNCTION: GetProcessHandleCount
! FUNCTION: GetProcessHeap
! FUNCTION: GetProcessHeaps
! FUNCTION: GetProcessId
! FUNCTION: GetProcessIoCounters
! FUNCTION: GetProcessPriorityBoost
! FUNCTION: GetProcessShutdownParameters
! FUNCTION: GetProcessTimes
! FUNCTION: GetProcessVersion
! FUNCTION: GetProcessWorkingSetSize
! FUNCTION: GetProfileIntA
! FUNCTION: GetProfileIntW
! FUNCTION: GetProfileSectionA
! FUNCTION: GetProfileSectionW
! FUNCTION: GetProfileStringA
! FUNCTION: GetProfileStringW
FUNCTION: BOOL GetQueuedCompletionStatus ( HANDLE hCompletionPort, LPDWORD lpNumberOfBytes, void* lpCompletionKey, LPOVERLAPPED lpOverlapped, DWORD dwMilliseconds ) ;
! FUNCTION: GetShortPathNameA
! FUNCTION: GetShortPathNameW
! FUNCTION: GetStartupInfoA
! FUNCTION: GetStartupInfoW
FUNCTION: HANDLE GetStdHandle ( DWORD nStdHandle ) ;
! FUNCTION: GetStringTypeA
! FUNCTION: GetStringTypeExA
! FUNCTION: GetStringTypeExW
! FUNCTION: GetStringTypeW
! FUNCTION: GetSystemDefaultLangID
! FUNCTION: GetSystemDefaultLCID
! FUNCTION: GetSystemDefaultUILanguage
! FUNCTION: GetSystemDirectoryA
! FUNCTION: GetSystemDirectoryW
FUNCTION: void GetSystemInfo ( LPSYSTEM_INFO lpSystemInfo ) ;
! FUNCTION: GetSystemPowerStatus
! FUNCTION: GetSystemRegistryQuota
FUNCTION: void GetSystemTime ( LPSYSTEMTIME lpSystemTime ) ;
! FUNCTION: GetSystemTimeAdjustment
FUNCTION: void GetSystemTimeAsFileTime ( LPFILETIME lpSystemTimeAsFileTime ) ;
! FUNCTION: GetSystemTimes
! FUNCTION: GetSystemWindowsDirectoryA
! FUNCTION: GetSystemWindowsDirectoryW
! FUNCTION: GetSystemWow64DirectoryA
! FUNCTION: GetSystemWow64DirectoryW
! FUNCTION: GetTapeParameters
! FUNCTION: GetTapePosition
! FUNCTION: GetTapeStatus
! FUNCTION: GetTempFileNameA
! FUNCTION: GetTempFileNameW
! FUNCTION: GetTempPathA
! FUNCTION: GetTempPathW
! FUNCTION: GetThreadContext
! FUNCTION: GetThreadIOPendingFlag
! FUNCTION: GetThreadLocale
! FUNCTION: GetThreadPriority
! FUNCTION: GetThreadPriorityBoost
! FUNCTION: GetThreadSelectorEntry
! FUNCTION: GetThreadTimes
! FUNCTION: GetTickCount
! FUNCTION: GetTimeFormatA
! FUNCTION: GetTimeFormatW
FUNCTION: DWORD GetTimeZoneInformation ( LPTIME_ZONE_INFORMATION lpTimeZoneInformation ) ;
! FUNCTION: GetUserDefaultLangID
! FUNCTION: GetUserDefaultLCID
! FUNCTION: GetUserDefaultUILanguage
! FUNCTION: GetUserGeoID
! FUNCTION: GetVDMCurrentDirectories
FUNCTION: DWORD GetVersion ( ) ;
FUNCTION: BOOL GetVersionExW ( LPOSVERSIONINFO lpVersionInfo ) ;
: GetVersionEx GetVersionExW ;
! FUNCTION: GetVolumeInformationA
! FUNCTION: GetVolumeInformationW
! FUNCTION: GetVolumeNameForVolumeMountPointA
! FUNCTION: GetVolumeNameForVolumeMountPointW
! FUNCTION: GetVolumePathNameA
! FUNCTION: GetVolumePathNamesForVolumeNameA
! FUNCTION: GetVolumePathNamesForVolumeNameW
! FUNCTION: GetVolumePathNameW
! FUNCTION: GetWindowsDirectoryA
! FUNCTION: GetWindowsDirectoryW
! FUNCTION: GetWriteWatch
! FUNCTION: GlobalAddAtomA
! FUNCTION: GlobalAddAtomW
FUNCTION: HGLOBAL GlobalAlloc ( UINT uFlags, SIZE_T dwBytes ) ;
! FUNCTION: GlobalCompact
! FUNCTION: GlobalDeleteAtom
! FUNCTION: GlobalFindAtomA
! FUNCTION: GlobalFindAtomW
! FUNCTION: GlobalFix
! FUNCTION: GlobalFlags
! FUNCTION: GlobalFree
! FUNCTION: GlobalGetAtomNameA
! FUNCTION: GlobalGetAtomNameW
! FUNCTION: GlobalHandle
FUNCTION: LPVOID GlobalLock ( HGLOBAL hMem ) ;
FUNCTION: void GlobalMemoryStatus ( LPMEMORYSTATUS lpBuffer ) ;
FUNCTION: BOOL GlobalMemoryStatusEx ( LPMEMORYSTATUSEX lpBuffer ) ;
! FUNCTION: GlobalReAlloc
! FUNCTION: GlobalSize
! FUNCTION: GlobalUnfix
FUNCTION: BOOL GlobalUnlock ( HGLOBAL hMem ) ;
! FUNCTION: GlobalUnWire
! FUNCTION: GlobalWire
! FUNCTION: Heap32First
! FUNCTION: Heap32ListFirst
! FUNCTION: Heap32ListNext
! FUNCTION: Heap32Next
! FUNCTION: HeapAlloc
! FUNCTION: HeapCompact
! FUNCTION: HeapCreate
! FUNCTION: HeapCreateTagsW
! FUNCTION: HeapDestroy
! FUNCTION: HeapExtend
! FUNCTION: HeapFree
! FUNCTION: HeapLock
! FUNCTION: HeapQueryInformation
! FUNCTION: HeapQueryTagW
! FUNCTION: HeapReAlloc
! FUNCTION: HeapSetInformation
! FUNCTION: HeapSize
! FUNCTION: HeapSummary
! FUNCTION: HeapUnlock
! FUNCTION: HeapUsage
! FUNCTION: HeapValidate
! FUNCTION: HeapWalk
! FUNCTION: InitAtomTable
! FUNCTION: InitializeCriticalSection
! FUNCTION: InitializeCriticalSectionAndSpinCount
! FUNCTION: InitializeSListHead
! FUNCTION: InterlockedCompareExchange
! FUNCTION: InterlockedDecrement
! FUNCTION: InterlockedExchange
! FUNCTION: InterlockedExchangeAdd
! FUNCTION: InterlockedFlushSList
! FUNCTION: InterlockedIncrement
! FUNCTION: InterlockedPopEntrySList
! FUNCTION: InterlockedPushEntrySList
! FUNCTION: InvalidateConsoleDIBits
! FUNCTION: IsBadCodePtr
! FUNCTION: IsBadHugeReadPtr
! FUNCTION: IsBadHugeWritePtr
! FUNCTION: IsBadReadPtr
! FUNCTION: IsBadStringPtrA
! FUNCTION: IsBadStringPtrW
! FUNCTION: IsBadWritePtr
! FUNCTION: IsDBCSLeadByte
! FUNCTION: IsDBCSLeadByteEx
! FUNCTION: IsDebuggerPresent
! FUNCTION: IsProcessInJob
FUNCTION: BOOL IsProcessorFeaturePresent ( DWORD ProcessorFeature ) ;
! FUNCTION: IsSystemResumeAutomatic
! FUNCTION: IsValidCodePage
! FUNCTION: IsValidLanguageGroup
! FUNCTION: IsValidLocale
! FUNCTION: IsValidUILanguage
! FUNCTION: IsWow64Process
! FUNCTION: LCMapStringA
! FUNCTION: LCMapStringW
! FUNCTION: LeaveCriticalSection
! FUNCTION: LoadLibraryA
! FUNCTION: LoadLibraryExA
! FUNCTION: LoadLibraryExW
! FUNCTION: LoadLibraryW
! FUNCTION: LoadModule
! FUNCTION: LoadResource
! FUNCTION: LocalAlloc
! FUNCTION: LocalCompact
! FUNCTION: LocalFileTimeToFileTime
! FUNCTION: LocalFlags
FUNCTION: HLOCAL LocalFree ( HLOCAL hMem ) ;
! FUNCTION: LocalHandle
! FUNCTION: LocalLock
! FUNCTION: LocalReAlloc
! FUNCTION: LocalShrink
! FUNCTION: LocalSize
! FUNCTION: LocalUnlock
! FUNCTION: LockFile
! FUNCTION: LockFileEx
! FUNCTION: LockResource
! FUNCTION: lstrcat
! FUNCTION: lstrcatA
! FUNCTION: lstrcatW
! FUNCTION: lstrcmp
! FUNCTION: lstrcmpA
! FUNCTION: lstrcmpi
! FUNCTION: lstrcmpiA
! FUNCTION: lstrcmpiW
! FUNCTION: lstrcmpW
! FUNCTION: lstrcpy
! FUNCTION: lstrcpyA
! FUNCTION: lstrcpyn
! FUNCTION: lstrcpynA
! FUNCTION: lstrcpynW
! FUNCTION: lstrcpyW
! FUNCTION: lstrlen
! FUNCTION: lstrlenA
! FUNCTION: lstrlenW
! FUNCTION: LZClose
! FUNCTION: LZCloseFile
! FUNCTION: LZCopy
! FUNCTION: LZCreateFileW
! FUNCTION: LZDone
! FUNCTION: LZInit
! FUNCTION: LZOpenFileA
! FUNCTION: LZOpenFileW
! FUNCTION: LZRead
! FUNCTION: LZSeek
! FUNCTION: LZStart
! FUNCTION: MapUserPhysicalPages
! FUNCTION: MapUserPhysicalPagesScatter
FUNCTION: LPVOID MapViewOfFile ( HANDLE hFileMappingObject,
                                 DWORD dwDesiredAccess,
                                 DWORD dwFileOffsetHigh,
                                 DWORD dwFileOffsetLow,
                                 SIZE_T dwNumberOfBytesToMap ) ;

FUNCTION: LPVOID MapViewOfFileEx ( HANDLE hFileMappingObject,
                                 DWORD dwDesiredAccess,
                                 DWORD dwFileOffsetHigh,
                                 DWORD dwFileOffsetLow,
                                 SIZE_T dwNumberOfBytesToMap,
                                 LPVOID lpBaseAddress ) ;

! FUNCTION: Module32First
! FUNCTION: Module32FirstW
! FUNCTION: Module32Next
! FUNCTION: Module32NextW
! FUNCTION: MoveFileA
! FUNCTION: MoveFileExA
! FUNCTION: MoveFileExW
FUNCTION: BOOL MoveFileW ( LPCTSTR lpExistingFileName, LPCTSTR lpNewFileName ) ;
: MoveFile MoveFileW ;
! FUNCTION: MoveFileWithProgressA
! FUNCTION: MoveFileWithProgressW
! FUNCTION: MulDiv
! FUNCTION: MultiByteToWideChar
! FUNCTION: NlsConvertIntegerToString
! FUNCTION: NlsGetCacheUpdateCount
! FUNCTION: NlsResetProcessLocale
! FUNCTION: NumaVirtualQueryNode
! FUNCTION: OpenConsoleW
! FUNCTION: OpenDataFile
! FUNCTION: OpenEventA
! FUNCTION: OpenEventW
! WARNING: OpenFile is limited to paths of 128 chars in length.  Do not use!
! FUNCTION: HFILE OpenFile ( LPCTSTR lpFileName, LPOFSTRUCT lpReOpenBuff, UINT uStyle ) ;
FUNCTION: HANDLE OpenFileMappingW ( DWORD dwDesiredAccess,
                                    BOOL bInheritHandle,
                                    LPCTSTR lpName ) ;
: OpenFileMapping OpenFileMappingW ;
! FUNCTION: OpenJobObjectA
! FUNCTION: OpenJobObjectW
! FUNCTION: OpenMutexA
! FUNCTION: OpenMutexW
FUNCTION: HANDLE OpenProcess ( DWORD dwDesiredAccess, BOOL bInheritHandle, DWORD dwProcessId ) ;
! FUNCTION: OpenProfileUserMapping
! FUNCTION: OpenSemaphoreA
! FUNCTION: OpenSemaphoreW
! FUNCTION: OpenThread
! FUNCTION: OpenWaitableTimerA
! FUNCTION: OpenWaitableTimerW
! FUNCTION: OutputDebugStringA
! FUNCTION: OutputDebugStringW
! FUNCTION: PeekConsoleInputA
! FUNCTION: PeekConsoleInputW
! FUNCTION: PeekNamedPipe
! FUNCTION: PostQueuedCompletionStatus
! FUNCTION: PrepareTape
! FUNCTION: PrivCopyFileExW
! FUNCTION: PrivMoveFileIdentityW
! FUNCTION: Process32First
! FUNCTION: Process32FirstW
! FUNCTION: Process32Next
! FUNCTION: Process32NextW
! FUNCTION: ProcessIdToSessionId
! FUNCTION: PulseEvent
! FUNCTION: PurgeComm
! FUNCTION: QueryActCtxW
! FUNCTION: QueryDepthSList
! FUNCTION: QueryDosDeviceA
! FUNCTION: QueryDosDeviceW
! FUNCTION: QueryInformationJobObject
! FUNCTION: QueryMemoryResourceNotification
! FUNCTION: QueryPerformanceCounter
! FUNCTION: QueryPerformanceFrequency
! FUNCTION: QueryWin31IniFilesMappedToRegistry
! FUNCTION: QueueUserAPC
! FUNCTION: QueueUserWorkItem
! FUNCTION: RaiseException
! FUNCTION: ReadConsoleA
! FUNCTION: ReadConsoleInputA
! FUNCTION: ReadConsoleInputExA
! FUNCTION: ReadConsoleInputExW
! FUNCTION: ReadConsoleInputW
! FUNCTION: ReadConsoleOutputA
! FUNCTION: ReadConsoleOutputAttribute
! FUNCTION: ReadConsoleOutputCharacterA
! FUNCTION: ReadConsoleOutputCharacterW
! FUNCTION: ReadConsoleOutputW
! FUNCTION: ReadConsoleW
FUNCTION: BOOL ReadDirectoryChangesW ( HANDLE hDirectory, LPVOID lpBuffer, DWORD nBufferLength, BOOL bWatchSubtree, DWORD dwNotifyFilter, LPDWORD lpBytesReturned, LPOVERLAPPED lpOverlapped, void* lpCompletionRoutine ) ;
FUNCTION: BOOL ReadFile ( HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, void* lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped ) ;
! FUNCTION: BOOL ReadFile ( HANDLE hFile, LPCVOID lpBuffer, DWORD nNumberOfBytesToRead, LPDWORD lpNumberOfBytesRead, LPOVERLAPPED lpOverlapped ) ;
FUNCTION: BOOL ReadFileEx ( HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToRead, LPOVERLAPPED lpOverlapped, LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;
! FUNCTION: ReadFileScatter
FUNCTION: BOOL ReadProcessMemory ( HANDLE hProcess, void* lpBaseAddress, void* lpBuffer, long nSize, long* lpNumberOfBytesRead )  ;
! FUNCTION: RegisterConsoleIME
! FUNCTION: RegisterConsoleOS2
! FUNCTION: RegisterConsoleVDM
! FUNCTION: RegisterWaitForInputIdle
! FUNCTION: RegisterWaitForSingleObject
! FUNCTION: RegisterWaitForSingleObjectEx
! FUNCTION: RegisterWowBaseHandlers
! FUNCTION: RegisterWowExec
! FUNCTION: ReleaseActCtx
! FUNCTION: ReleaseMutex
! FUNCTION: ReleaseSemaphore
! FUNCTION: RemoveDirectoryA
FUNCTION: BOOL RemoveDirectoryW ( LPCTSTR lpPathName ) ;
: RemoveDirectory RemoveDirectoryW ;
! FUNCTION: RemoveLocalAlternateComputerNameA
! FUNCTION: RemoveLocalAlternateComputerNameW
! FUNCTION: RemoveVectoredExceptionHandler
! FUNCTION: ReplaceFile
! FUNCTION: ReplaceFileA
! FUNCTION: ReplaceFileW
! FUNCTION: RequestDeviceWakeup
! FUNCTION: RequestWakeupLatency
! FUNCTION: ResetEvent
! FUNCTION: ResetWriteWatch
! FUNCTION: RestoreLastError
! FUNCTION: ResumeThread
! FUNCTION: RtlCaptureContext
! FUNCTION: RtlCaptureStackBackTrace
! FUNCTION: RtlFillMemory
! FUNCTION: RtlMoveMemory
! FUNCTION: RtlUnwind
! FUNCTION: RtlZeroMemory
! FUNCTION: ScrollConsoleScreenBufferA
! FUNCTION: ScrollConsoleScreenBufferW
! FUNCTION: SearchPathA
! FUNCTION: SearchPathW
! FUNCTION: SetCalendarInfoA
! FUNCTION: SetCalendarInfoW
! FUNCTION: SetClientTimeZoneInformation
! FUNCTION: SetCommBreak
! FUNCTION: SetCommConfig
! FUNCTION: SetCommMask
! FUNCTION: SetCommState
! FUNCTION: SetCommTimeouts
! FUNCTION: SetComPlusPackageInstallStatus
! FUNCTION: SetComputerNameA
! FUNCTION: SetComputerNameExA
! FUNCTION: SetComputerNameExW
! FUNCTION: SetComputerNameW
! FUNCTION: SetConsoleActiveScreenBuffer
! FUNCTION: SetConsoleCommandHistoryMode
! FUNCTION: SetConsoleCP
! FUNCTION: SetConsoleCtrlHandler
! FUNCTION: SetConsoleCursor
! FUNCTION: SetConsoleCursorInfo
! FUNCTION: SetConsoleCursorMode
! FUNCTION: SetConsoleCursorPosition
! FUNCTION: SetConsoleDisplayMode
! FUNCTION: SetConsoleFont
! FUNCTION: SetConsoleHardwareState
! FUNCTION: SetConsoleIcon
! FUNCTION: SetConsoleInputExeNameA
! FUNCTION: SetConsoleInputExeNameW
! FUNCTION: SetConsoleKeyShortcuts
! FUNCTION: SetConsoleLocalEUDC
! FUNCTION: SetConsoleMaximumWindowSize
! FUNCTION: SetConsoleMenuClose
! FUNCTION: SetConsoleMode
! FUNCTION: SetConsoleNlsMode
! FUNCTION: SetConsoleNumberOfCommandsA
! FUNCTION: SetConsoleNumberOfCommandsW
! FUNCTION: SetConsoleOS2OemFormat
! FUNCTION: SetConsoleOutputCP
! FUNCTION: SetConsolePalette
! FUNCTION: SetConsoleScreenBufferSize
FUNCTION: BOOL SetConsoleTextAttribute ( HANDLE hConsoleOutput, WORD wAttributes ) ;
FUNCTION: BOOL SetConsoleTitleW ( LPCWSTR lpConsoleTitle ) ;
: SetConsoleTitle SetConsoleTitleW ;
! FUNCTION: SetConsoleWindowInfo
! FUNCTION: SetCPGlobal
! FUNCTION: SetCriticalSectionSpinCount
! FUNCTION: SetCurrentDirectoryA
! FUNCTION: SetCurrentDirectoryW
! FUNCTION: SetDefaultCommConfigA
! FUNCTION: SetDefaultCommConfigW
! FUNCTION: SetDllDirectoryA
! FUNCTION: SetDllDirectoryW
FUNCTION: BOOL SetEndOfFile ( HANDLE hFile ) ;
! FUNCTION: SetEnvironmentVariableA
! FUNCTION: SetEnvironmentVariableW
! FUNCTION: SetErrorMode
! FUNCTION: SetEvent
! FUNCTION: SetFileApisToANSI
! FUNCTION: SetFileApisToOEM
! FUNCTION: SetFileAttributesA
! FUNCTION: SetFileAttributesW
FUNCTION: DWORD SetFilePointer ( HANDLE hFile, LONG lDistanceToMove, PLONG lpDistanceToMoveHigh, DWORD dwMoveMethod ) ;
FUNCTION: DWORD SetFilePointerEx ( HANDLE hFile, LARGE_INTEGER lDistanceToMove, PLARGE_INTEGER lpDistanceToMoveHigh, DWORD dwMoveMethod ) ;
! FUNCTION: SetFileShortNameA
! FUNCTION: SetFileShortNameW
FUNCTION: BOOL SetFileTime ( HANDLE hFile, FILETIME* lpCreationTime, FILETIME* lpLastAccessTime, FILETIME* lpLastWriteTime ) ;
! FUNCTION: SetFileValidData
! FUNCTION: SetFirmwareEnvironmentVariableA
! FUNCTION: SetFirmwareEnvironmentVariableW
! FUNCTION: SetHandleContext
! FUNCTION: SetHandleCount
FUNCTION: BOOL SetHandleInformation ( HANDLE hObject, DWORD dwMask, DWORD dwFlags ) ;
! FUNCTION: SetInformationJobObject
! FUNCTION: SetLastConsoleEventActive
! FUNCTION: SetLastError
! FUNCTION: SetLocaleInfoA
! FUNCTION: SetLocaleInfoW
! FUNCTION: SetLocalPrimaryComputerNameA
! FUNCTION: SetLocalPrimaryComputerNameW
! FUNCTION: SetLocalTime
! FUNCTION: SetMailslotInfo
! FUNCTION: SetMessageWaitingIndicator
! FUNCTION: SetNamedPipeHandleState
! FUNCTION: SetPriorityClass
! FUNCTION: SetProcessAffinityMask
! FUNCTION: SetProcessPriorityBoost
! FUNCTION: SetProcessShutdownParameters
! FUNCTION: SetProcessWorkingSetSize
! FUNCTION: SetStdHandle
! FUNCTION: SetSystemPowerState
! FUNCTION: SetSystemTime
! FUNCTION: SetSystemTimeAdjustment
! FUNCTION: SetTapeParameters
! FUNCTION: SetTapePosition
! FUNCTION: SetTermsrvAppInstallMode
! FUNCTION: SetThreadAffinityMask
! FUNCTION: SetThreadContext
! FUNCTION: SetThreadExecutionState
! FUNCTION: SetThreadIdealProcessor
! FUNCTION: SetThreadLocale
! FUNCTION: SetThreadPriority
! FUNCTION: SetThreadPriorityBoost
! FUNCTION: SetThreadUILanguage
! FUNCTION: SetTimerQueueTimer
! FUNCTION: SetTimeZoneInformation
! FUNCTION: SetUnhandledExceptionFilter
! FUNCTION: SetupComm
! FUNCTION: SetUserGeoID
! FUNCTION: SetVDMCurrentDirectories
! FUNCTION: SetVolumeLabelA
! FUNCTION: SetVolumeLabelW
! FUNCTION: SetVolumeMountPointA
! FUNCTION: SetVolumeMountPointW
! FUNCTION: SetWaitableTimer
! FUNCTION: ShowConsoleCursor
! FUNCTION: SignalObjectAndWait
! FUNCTION: SizeofResource
! FUNCTION: Sleep
FUNCTION: DWORD SleepEx ( DWORD dwMilliSeconds, BOOL bAlertable ) ;
! FUNCTION: SuspendThread
! FUNCTION: SwitchToFiber
! FUNCTION: SwitchToThread
FUNCTION: BOOL SystemTimeToFileTime ( SYSTEMTIME* lpSystemTime, LPFILETIME lpFileTime ) ;
! FUNCTION: SystemTimeToTzSpecificLocalTime
! FUNCTION: TerminateJobObject
! FUNCTION: TerminateProcess
! FUNCTION: TerminateThread
! FUNCTION: TermsrvAppInstallMode
! FUNCTION: Thread32First
! FUNCTION: Thread32Next
! FUNCTION: TlsAlloc
! FUNCTION: TlsFree
! FUNCTION: TlsGetValue
! FUNCTION: TlsSetValue
! FUNCTION: Toolhelp32ReadProcessMemory
! FUNCTION: TransactNamedPipe
! FUNCTION: TransmitCommChar
! FUNCTION: TrimVirtualBuffer
! FUNCTION: TryEnterCriticalSection
! FUNCTION: TzSpecificLocalTimeToSystemTime
! FUNCTION: UnhandledExceptionFilter
! FUNCTION: UnlockFile
! FUNCTION: UnlockFileEx
FUNCTION: BOOL UnmapViewOfFile ( LPCVOID lpBaseAddress ) ;
! FUNCTION: UnregisterConsoleIME
! FUNCTION: UnregisterWait
! FUNCTION: UnregisterWaitEx
! FUNCTION: UpdateResourceA
! FUNCTION: UpdateResourceW
! FUNCTION: UTRegister
! FUNCTION: UTUnRegister
! FUNCTION: ValidateLCType
! FUNCTION: ValidateLocale
! FUNCTION: VDMConsoleOperation
! FUNCTION: VDMOperationStarted
! FUNCTION: VerifyConsoleIoHandle
! FUNCTION: VerifyVersionInfoA
! FUNCTION: VerifyVersionInfoW
! FUNCTION: VerLanguageNameA
! FUNCTION: VerLanguageNameW
! FUNCTION: VerSetConditionMask
! FUNCTION: VirtualAlloc
FUNCTION: HANDLE VirtualAllocEx ( HANDLE hProcess, void* lpAddress, long dwSize, DWORD flAllocationType, DWORD flProtect ) ;
! FUNCTION: VirtualBufferExceptionHandler
! FUNCTION: VirtualFree
FUNCTION: BOOL VirtualFreeEx ( HANDLE hProcess, void* lpAddress, long dwSize, DWORD dwFreeType ) ;
! FUNCTION: VirtualLock
! FUNCTION: VirtualProtect
! FUNCTION: VirtualProtectEx
! FUNCTION: VirtualQuery
FUNCTION: BOOL VirtualQueryEx ( HANDLE hProcess, void* lpAddress, MEMORY_BASIC_INFORMATION* lpBuffer, SIZE_T dwLength ) ;
! FUNCTION: VirtualUnlock
! FUNCTION: WaitCommEvent
! FUNCTION: WaitForDebugEvent
! FUNCTION: WaitForMultipleObjects
! FUNCTION: WaitForMultipleObjectsEx
! FUNCTION: WaitForSingleObject
! FUNCTION: WaitForSingleObjectEx
! FUNCTION: WaitNamedPipeA
! FUNCTION: WaitNamedPipeW
! FUNCTION: WideCharToMultiByte
! FUNCTION: WinExec
! FUNCTION: WriteConsoleA
! FUNCTION: WriteConsoleInputA
! FUNCTION: WriteConsoleInputVDMA
! FUNCTION: WriteConsoleInputVDMW
! FUNCTION: WriteConsoleInputW
! FUNCTION: WriteConsoleOutputA
! FUNCTION: WriteConsoleOutputAttribute
! FUNCTION: WriteConsoleOutputCharacterA
! FUNCTION: WriteConsoleOutputCharacterW
! FUNCTION: WriteConsoleOutputW
! FUNCTION: WriteConsoleW
FUNCTION: BOOL WriteFile ( HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToWrite, void* lpNumberOfBytesWritten, LPOVERLAPPED lpOverlapped ) ;
FUNCTION: BOOL WriteFileEx ( HANDLE hFile, LPVOID lpBuffer, DWORD nNumberOfBytesToWrite, LPOVERLAPPED lpOverlapped, LPOVERLAPPED_COMPLETION_ROUTINE lpCompletionRoutine ) ;
! FUNCTION: WriteFileGather
! FUNCTION: WritePrivateProfileSectionA
! FUNCTION: WritePrivateProfileSectionW
! FUNCTION: WritePrivateProfileStringA
! FUNCTION: WritePrivateProfileStringW
! FUNCTION: WritePrivateProfileStructA
! FUNCTION: WritePrivateProfileStructW
FUNCTION: BOOL WriteProcessMemory ( HANDLE hProcess, void* lpBaseAddress, void* lpBuffer, long nSize, long* lpNumberOfBytesWritten )  ;
! FUNCTION: WriteProfileSectionA
! FUNCTION: WriteProfileSectionW
! FUNCTION: WriteProfileStringA
! FUNCTION: WriteProfileStringW
! FUNCTION: WriteTapemark
! FUNCTION: WTSGetActiveConsoleSessionId
! FUNCTION: ZombifyActCtx
