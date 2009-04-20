! Copyright (C) 2005, 2006 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien alien.syntax kernel windows.types multiline ;
IN: windows.kernel32

CONSTANT: MAX_PATH 260

CONSTANT: GHND          HEX: 40
CONSTANT: GMEM_FIXED          0
CONSTANT: GMEM_MOVEABLE       2
CONSTANT: GMEM_ZEROINIT HEX: 40
CONSTANT: GPTR          HEX: 40

CONSTANT: GENERIC_READ    HEX: 80000000
CONSTANT: GENERIC_WRITE   HEX: 40000000
CONSTANT: GENERIC_EXECUTE HEX: 20000000
CONSTANT: GENERIC_ALL     HEX: 10000000

CONSTANT: CREATE_NEW        1
CONSTANT: CREATE_ALWAYS     2
CONSTANT: OPEN_EXISTING     3
CONSTANT: OPEN_ALWAYS       4
CONSTANT: TRUNCATE_EXISTING 5
              
CONSTANT: FILE_LIST_DIRECTORY       HEX: 00000001
CONSTANT: FILE_READ_DAT             HEX: 00000001
CONSTANT: FILE_ADD_FILE             HEX: 00000002
CONSTANT: FILE_WRITE_DATA           HEX: 00000002
CONSTANT: FILE_ADD_SUBDIRECTORY     HEX: 00000004
CONSTANT: FILE_APPEND_DATA          HEX: 00000004
CONSTANT: FILE_CREATE_PIPE_INSTANCE HEX: 00000004
CONSTANT: FILE_READ_EA              HEX: 00000008
CONSTANT: FILE_READ_PROPERTIES      HEX: 00000008
CONSTANT: FILE_WRITE_EA             HEX: 00000010
CONSTANT: FILE_WRITE_PROPERTIES     HEX: 00000010
CONSTANT: FILE_EXECUTE              HEX: 00000020
CONSTANT: FILE_TRAVERSE             HEX: 00000020
CONSTANT: FILE_DELETE_CHILD         HEX: 00000040
CONSTANT: FILE_READ_ATTRIBUTES      HEX: 00000080
CONSTANT: FILE_WRITE_ATTRIBUTES     HEX: 00000100

CONSTANT: FILE_SHARE_READ        1
CONSTANT: FILE_SHARE_WRITE       2
CONSTANT: FILE_SHARE_DELETE      4
CONSTANT: FILE_SHARE_VALID_FLAGS 7

CONSTANT: FILE_FLAG_WRITE_THROUGH       HEX: 80000000
CONSTANT: FILE_FLAG_OVERLAPPED          HEX: 40000000
CONSTANT: FILE_FLAG_NO_BUFFERING        HEX: 20000000
CONSTANT: FILE_FLAG_RANDOM_ACCESS       HEX: 10000000
CONSTANT: FILE_FLAG_SEQUENTIAL_SCAN     HEX: 08000000
CONSTANT: FILE_FLAG_DELETE_ON_CLOSE     HEX: 04000000
CONSTANT: FILE_FLAG_BACKUP_SEMANTICS    HEX: 02000000
CONSTANT: FILE_FLAG_POSIX_SEMANTICS     HEX: 01000000
CONSTANT: FILE_FLAG_OPEN_REPARSE_POINT  HEX: 00200000
CONSTANT: FILE_FLAG_OPEN_NO_RECALL      HEX: 00100000
CONSTANT: FILE_FLAG_FIRST_PIPE_INSTANCE HEX: 00080000

CONSTANT: FILE_ATTRIBUTE_READONLY            HEX: 00000001
CONSTANT: FILE_ATTRIBUTE_HIDDEN              HEX: 00000002
CONSTANT: FILE_ATTRIBUTE_SYSTEM              HEX: 00000004
CONSTANT: FILE_ATTRIBUTE_DIRECTORY           HEX: 00000010
CONSTANT: FILE_ATTRIBUTE_ARCHIVE             HEX: 00000020
CONSTANT: FILE_ATTRIBUTE_DEVICE              HEX: 00000040
CONSTANT: FILE_ATTRIBUTE_NORMAL              HEX: 00000080
CONSTANT: FILE_ATTRIBUTE_TEMPORARY           HEX: 00000100
CONSTANT: FILE_ATTRIBUTE_SPARSE_FILE         HEX: 00000200
CONSTANT: FILE_ATTRIBUTE_REPARSE_POINT       HEX: 00000400
CONSTANT: FILE_ATTRIBUTE_COMPRESSED          HEX: 00000800
CONSTANT: FILE_ATTRIBUTE_OFFLINE             HEX: 00001000
CONSTANT: FILE_ATTRIBUTE_NOT_CONTENT_INDEXED HEX: 00002000
CONSTANT: FILE_ATTRIBUTE_ENCRYPTED           HEX: 00004000

CONSTANT: FILE_NOTIFY_CHANGE_FILE        HEX: 001
CONSTANT: FILE_NOTIFY_CHANGE_DIR_NAME    HEX: 002
CONSTANT: FILE_NOTIFY_CHANGE_ATTRIBUTES  HEX: 004
CONSTANT: FILE_NOTIFY_CHANGE_SIZE        HEX: 008
CONSTANT: FILE_NOTIFY_CHANGE_LAST_WRITE  HEX: 010
CONSTANT: FILE_NOTIFY_CHANGE_LAST_ACCESS HEX: 020
CONSTANT: FILE_NOTIFY_CHANGE_CREATION    HEX: 040
CONSTANT: FILE_NOTIFY_CHANGE_EA          HEX: 080
CONSTANT: FILE_NOTIFY_CHANGE_SECURITY    HEX: 100
CONSTANT: FILE_NOTIFY_CHANGE_FILE_NAME   HEX: 200
CONSTANT: FILE_NOTIFY_CHANGE_ALL         HEX: 3ff

CONSTANT: FILE_ACTION_ADDED 1
CONSTANT: FILE_ACTION_REMOVED 2
CONSTANT: FILE_ACTION_MODIFIED 3
CONSTANT: FILE_ACTION_RENAMED_OLD_NAME 4
CONSTANT: FILE_ACTION_RENAMED_NEW_NAME 5

C-STRUCT: FILE_NOTIFY_INFORMATION
    { "DWORD" "NextEntryOffset" }
    { "DWORD" "Action" }
    { "DWORD" "FileNameLength" }
    { "WCHAR[1]" "FileName" } ;
TYPEDEF: FILE_NOTIFY_INFORMATION* PFILE_NOTIFY_INFORMATION

CONSTANT: STD_INPUT_HANDLE  -10
CONSTANT: STD_OUTPUT_HANDLE -11
CONSTANT: STD_ERROR_HANDLE  -12

: INVALID_HANDLE_VALUE ( -- alien ) -1 <alien> ; inline
CONSTANT: INVALID_FILE_SIZE HEX: FFFFFFFF
CONSTANT: INVALID_SET_FILE_POINTER HEX: ffffffff

CONSTANT: FILE_BEGIN 0
CONSTANT: FILE_CURRENT 1
CONSTANT: FILE_END 2

CONSTANT: OF_READ 0
CONSTANT: OF_READWRITE    2
CONSTANT: OF_WRITE    1
CONSTANT: OF_SHARE_COMPAT    0
CONSTANT: OF_SHARE_DENY_NONE    64
CONSTANT: OF_SHARE_DENY_READ    48
CONSTANT: OF_SHARE_DENY_WRITE    32
CONSTANT: OF_SHARE_EXCLUSIVE    16
CONSTANT: OF_CANCEL    2048
CONSTANT: OF_CREATE    4096
CONSTANT: OF_DELETE    512
CONSTANT: OF_EXIST    16384
CONSTANT: OF_PARSE    256
CONSTANT: OF_PROMPT    8192
CONSTANT: OF_REOPEN    32768
CONSTANT: OF_VERIFY    1024

CONSTANT: INFINITE HEX: FFFFFFFF

! From C:\cygwin\usr\include\w32api\winbase.h
CONSTANT: FILE_TYPE_UNKNOWN 0
CONSTANT: FILE_TYPE_DISK 1
CONSTANT: FILE_TYPE_CHAR 2
CONSTANT: FILE_TYPE_PIPE 3
CONSTANT: FILE_TYPE_REMOTE HEX: 8000

CONSTANT: TIME_ZONE_ID_UNKNOWN 0
CONSTANT: TIME_ZONE_ID_STANDARD 1
CONSTANT: TIME_ZONE_ID_DAYLIGHT 2
CONSTANT: TIME_ZONE_ID_INVALID HEX: FFFFFFFF

CONSTANT: PF_XMMI64_INSTRUCTIONS_AVAILABLE 10
CONSTANT: PF_SSE3_INSTRUCTIONS_AVAILABLE 13

CONSTANT: MAX_COMPUTERNAME_LENGTH 15
CONSTANT: UNLEN 256

CONSTANT: PROCESS_TERMINATE HEX: 1
CONSTANT: PROCESS_CREATE_THREAD HEX: 2
CONSTANT: PROCESS_VM_OPERATION HEX: 8
CONSTANT: PROCESS_VM_READ HEX: 10
CONSTANT: PROCESS_VM_WRITE HEX: 20
CONSTANT: PROCESS_DUP_HANDLE HEX: 40
CONSTANT: PROCESS_CREATE_PROCESS HEX: 80
CONSTANT: PROCESS_SET_QUOTA HEX: 100
CONSTANT: PROCESS_SET_INFORMATION HEX: 200
CONSTANT: PROCESS_QUERY_INFORMATION HEX: 400

CONSTANT: MEM_COMMIT HEX: 1000
CONSTANT: MEM_RELEASE  HEX: 8000

CONSTANT: PAGE_NOACCESS    1
CONSTANT: PAGE_READONLY    2
CONSTANT: PAGE_READWRITE 4
CONSTANT: PAGE_WRITECOPY 8
CONSTANT: PAGE_EXECUTE HEX: 10
CONSTANT: PAGE_EXECUTE_READ HEX: 20
CONSTANT: PAGE_EXECUTE_READWRITE HEX: 40
CONSTANT: PAGE_EXECUTE_WRITECOPY HEX: 80
CONSTANT: PAGE_GUARD HEX: 100
CONSTANT: PAGE_NOCACHE HEX: 200

CONSTANT: SEC_BASED HEX: 00200000
CONSTANT: SEC_NO_CHANGE HEX: 00400000
CONSTANT: SEC_FILE HEX: 00800000
CONSTANT: SEC_IMAGE HEX: 01000000
CONSTANT: SEC_VLM HEX: 02000000
CONSTANT: SEC_RESERVE HEX: 04000000
CONSTANT: SEC_COMMIT HEX: 08000000
CONSTANT: SEC_NOCACHE HEX: 10000000
ALIAS: MEM_IMAGE SEC_IMAGE

CONSTANT: ERROR_ALREADY_EXISTS 183

CONSTANT: FILE_MAP_ALL_ACCESS HEX: f001f
CONSTANT: FILE_MAP_READ   4
CONSTANT: FILE_MAP_WRITE  2
CONSTANT: FILE_MAP_COPY   1

CONSTANT: THREAD_MODE_BACKGROUND_BEGIN HEX: 10000
CONSTANT: THREAD_MODE_BACKGROUND_END   HEX: 20000
CONSTANT: THREAD_PRIORITY_ABOVE_NORMAL 1
CONSTANT: THREAD_PRIORITY_BELOW_NORMAL -1
CONSTANT: THREAD_PRIORITY_HIGHEST 2
CONSTANT: THREAD_PRIORITY_IDLE -15
CONSTANT: THREAD_PRIORITY_LOWEST -2
CONSTANT: THREAD_PRIORITY_NORMAL 0
CONSTANT: THREAD_PRIORITY_TIME_CRITICAL 15

C-ENUM:
    ComputerNameNetBIOS
    ComputerNameDnsHostname
    ComputerNameDnsDomain
    ComputerNameDnsFullyQualified
    ComputerNamePhysicalNetBIOS
    ComputerNamePhysicalDnsHostname
    ComputerNamePhysicalDnsDomain
    ComputerNamePhysicalDnsFullyQualified
    ComputerNameMax ;

TYPEDEF: uint COMPUTER_NAME_FORMAT

C-STRUCT: OVERLAPPED
    { "UINT_PTR" "internal" }
    { "UINT_PTR" "internal-high" }
    { "DWORD" "offset" }
    { "DWORD" "offset-high" }
    { "HANDLE" "event" } ;

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
    { "ULONG" "Data1" }
    { "WORD"  "Data2" }
    { "WORD"  "Data3" }
    { { "UCHAR" 8 } "Data4" } ;

/*
    fBinary  :1;
    fParity  :1;
    fOutxCtsFlow  :1;
    fOutxDsrFlow  :1;
    fDtrControl  :2;
    fDsrSensitivity  :1;
    fTXContinueOnXoff  :1;
    fOutX  :1;
    fInX  :1;
    fErrorChar  :1;
    fNull  :1;
    fRtsControl  :2;
    fAbortOnError  :1;
    fDummy2  :17;
*/

CONSTANT: SP_SERIALCOMM   HEX: 1
CONSTANT: BAUD_075        HEX: 1
CONSTANT: BAUD_110        HEX: 2
CONSTANT: BAUD_134_5      HEX: 4
CONSTANT: BAUD_150        HEX: 8
CONSTANT: BAUD_300        HEX: 10
CONSTANT: BAUD_600        HEX: 20
CONSTANT: BAUD_1200       HEX: 40
CONSTANT: BAUD_1800       HEX: 80
CONSTANT: BAUD_2400       HEX: 100
CONSTANT: BAUD_4800       HEX: 200
CONSTANT: BAUD_7200       HEX: 400
CONSTANT: BAUD_9600       HEX: 800
CONSTANT: BAUD_14400      HEX: 1000
CONSTANT: BAUD_19200      HEX: 2000
CONSTANT: BAUD_38400      HEX: 4000
CONSTANT: BAUD_56K        HEX: 8000
CONSTANT: BAUD_57600      HEX: 40000
CONSTANT: BAUD_115200     HEX: 20000
CONSTANT: BAUD_128K       HEX: 10000
CONSTANT: BAUD_USER       HEX: 10000000
CONSTANT: PST_FAX     HEX: 21
CONSTANT: PST_LAT     HEX: 101
CONSTANT: PST_MODEM       HEX: 6
CONSTANT: PST_NETWORK_BRIDGE  HEX: 100
CONSTANT: PST_PARALLELPORT    HEX: 2
CONSTANT: PST_RS232       HEX: 1
CONSTANT: PST_RS422       HEX: 3
CONSTANT: PST_RS423       HEX: 4
CONSTANT: PST_RS449       HEX: 5
CONSTANT: PST_SCANNER     HEX: 22
CONSTANT: PST_TCPIP_TELNET    HEX: 102
CONSTANT: PST_UNSPECIFIED 0
CONSTANT: PST_X25     HEX: 103
CONSTANT: PCF_16BITMODE   HEX: 200
CONSTANT: PCF_DTRDSR      HEX: 1
CONSTANT: PCF_INTTIMEOUTS HEX: 80
CONSTANT: PCF_PARITY_CHECK    HEX: 8
CONSTANT: PCF_RLSD        HEX: 4
CONSTANT: PCF_RTSCTS      HEX: 2
CONSTANT: PCF_SETXCHAR    HEX: 20
CONSTANT: PCF_SPECIALCHARS    HEX: 100
CONSTANT: PCF_TOTALTIMEOUTS   HEX: 40
CONSTANT: PCF_XONXOFF     HEX: 10
CONSTANT: SP_BAUD     HEX: 2
CONSTANT: SP_DATABITS     HEX: 4
CONSTANT: SP_HANDSHAKING  HEX: 10
CONSTANT: SP_PARITY       HEX: 1
CONSTANT: SP_PARITY_CHECK HEX: 20
CONSTANT: SP_RLSD     HEX: 40
CONSTANT: SP_STOPBITS     HEX: 8
CONSTANT: DATABITS_5      1
CONSTANT: DATABITS_6      2
CONSTANT: DATABITS_7      4
CONSTANT: DATABITS_8      8
CONSTANT: DATABITS_16     16
CONSTANT: DATABITS_16X    32
CONSTANT: STOPBITS_10     1
CONSTANT: STOPBITS_15     2
CONSTANT: STOPBITS_20     4
CONSTANT: PARITY_NONE     256
CONSTANT: PARITY_ODD      512
CONSTANT: PARITY_EVEN     1024
CONSTANT: PARITY_MARK     2048
CONSTANT: PARITY_SPACE    4096
CONSTANT: COMMPROP_INITIALIZED    HEX: e73cf52e

CONSTANT: CBR_110         110
CONSTANT: CBR_300         300
CONSTANT: CBR_600         600
CONSTANT: CBR_1200            1200
CONSTANT: CBR_2400            2400
CONSTANT: CBR_4800            4800
CONSTANT: CBR_9600            9600
CONSTANT: CBR_14400           14400
CONSTANT: CBR_19200           19200
CONSTANT: CBR_38400           38400
CONSTANT: CBR_56000           56000
CONSTANT: CBR_57600           57600
CONSTANT: CBR_115200          115200
CONSTANT: CBR_128000          128000
CONSTANT: CBR_256000          256000
CONSTANT: DTR_CONTROL_DISABLE     0
CONSTANT: DTR_CONTROL_ENABLE      1
CONSTANT: DTR_CONTROL_HANDSHAKE   2
CONSTANT: RTS_CONTROL_DISABLE     0
CONSTANT: RTS_CONTROL_ENABLE      1
CONSTANT: RTS_CONTROL_HANDSHAKE   2
CONSTANT: RTS_CONTROL_TOGGLE      3
CONSTANT: EVENPARITY          2
CONSTANT: MARKPARITY          3
CONSTANT: NOPARITY            0
CONSTANT: ODDPARITY           1
CONSTANT: SPACEPARITY         4
CONSTANT: ONESTOPBIT          0
CONSTANT: ONE5STOPBITS        1
CONSTANT: TWOSTOPBITS         2

! Flowcontrol bit mask in DCB
CONSTANT: FM_fBinary          HEX: 1
CONSTANT: FM_fParity          HEX: 2
CONSTANT: FM_fOutxCtsFlow     HEX: 4
CONSTANT: FM_fOutxDsrFlow     HEX: 8
CONSTANT: FM_fDtrControl      HEX: 30
CONSTANT: FM_fDsrSensitivity      HEX: 40
CONSTANT: FM_fTXContinueOnXoff    HEX: 80
CONSTANT: FM_fOutX            HEX: 100
CONSTANT: FM_fInX         HEX: 200
CONSTANT: FM_fErrorChar       HEX: 400
CONSTANT: FM_fNull            HEX: 800
CONSTANT: FM_fRtsControl      HEX: 3000
CONSTANT: FM_fAbortOnError        HEX: 4000
CONSTANT: FM_fDummy2          HEX: ffff8000

CONSTANT: BM_fCtsHold     HEX: 1
CONSTANT: BM_fDsrHold     HEX: 2
CONSTANT: BM_fRlsdHold    HEX: 4
CONSTANT: BM_fXoffHold    HEX: 8
CONSTANT: BM_fXoffSent    HEX: 10
CONSTANT: BM_fEof     HEX: 20
CONSTANT: BM_fTxim        HEX: 40
CONSTANT: BM_AllBits      HEX: 7f

! PurgeComm bit mask
CONSTANT: PURGE_TXABORT   HEX: 1
CONSTANT: PURGE_RXABORT   HEX: 2
CONSTANT: PURGE_TXCLEAR   HEX: 4
CONSTANT: PURGE_RXCLEAR   HEX: 8

! GetCommModemStatus bit mask
CONSTANT: MS_CTS_ON       HEX: 10
CONSTANT: MS_DSR_ON       HEX: 20
CONSTANT: MS_RING_ON      HEX: 40
CONSTANT: MS_RLSD_ON      HEX: 80

! EscapeCommFunction operations
CONSTANT: SETXOFF     HEX: 1
CONSTANT: SETXON      HEX: 2
CONSTANT: SETRTS      HEX: 3
CONSTANT: CLRRTS      HEX: 4
CONSTANT: SETDTR      HEX: 5
CONSTANT: CLRDTR      HEX: 6
CONSTANT: SETBREAK        HEX: 8
CONSTANT: CLRBREAK        HEX: 9

! ClearCommError bit mask
CONSTANT: CE_RXOVER       HEX: 1
CONSTANT: CE_OVERRUN      HEX: 2
CONSTANT: CE_RXPARITY     HEX: 4
CONSTANT: CE_FRAME        HEX: 8
CONSTANT: CE_BREAK        HEX: 10
CONSTANT: CE_TXFULL       HEX: 100
! LPT only
CONSTANT: CE_PTO        HEX: 200
CONSTANT: CE_IOE        HEX: 400
CONSTANT: CE_DNS        HEX: 800
CONSTANT: CE_OOP        HEX: 1000
! LPT only
CONSTANT: CE_MODE     HEX: 8000

! GetCommMask bits
CONSTANT: EV_RXCHAR       HEX: 1
CONSTANT: EV_RXFLAG       HEX: 2
CONSTANT: EV_TXEMPTY      HEX: 4
CONSTANT: EV_CTS      HEX: 8
CONSTANT: EV_DSR      HEX: 10
CONSTANT: EV_RLSD     HEX: 20
CONSTANT: EV_BREAK        HEX: 40
CONSTANT: EV_ERR      HEX: 80
CONSTANT: EV_RING     HEX: 100
CONSTANT: EV_PERR     HEX: 200
CONSTANT: EV_RX80FULL     HEX: 400
CONSTANT: EV_EVENT1       HEX: 800
CONSTANT: EV_EVENT2       HEX: 1000

C-STRUCT: DCB
    { "DWORD" "DCBlength" }
    { "DWORD" "BaudRate" }
    { "DWORD" "flags" }
    { "WORD"  "wReserved" }
    { "WORD"  "XonLim" }
    { "WORD"  "XoffLim" }
    { "BYTE"  "ByteSize" }
    { "BYTE"  "Parity" }
    { "BYTE"  "StopBits" }
    { "char"  "XonChar" }
    { "char"  "XoffChar" }
    { "char"  "ErrorChar" }
    { "char"  "EofChar" }
    { "char"  "EvtChar" }
    { "WORD"  "wReserved1" } ;
TYPEDEF: DCB* PDCB
TYPEDEF: DCB* LPDCB

C-STRUCT: COMM_CONFIG
    { "DWORD" "dwSize" }
    { "WORD" "wVersion" }
    { "WORD" "wReserved" }
    { "DCB" "dcb" }
    { "DWORD" "dwProviderSubType" }
    { "DWORD" "dwProviderOffset" }
    { "DWORD" "dwProviderSize" }
    { { "WCHAR" 1 } "wcProviderData" } ;
TYPEDEF: COMMCONFIG* LPCOMMCONFIG

C-STRUCT: COMMPROP
    { "WORD" "wPacketLength" }
    { "WORD" "wPacketVersion" }
    { "DWORD" "dwServiceMask" }
    { "DWORD" "dwReserved1" }
    { "DWORD" "dwMaxTxQueue" }
    { "DWORD" "dwMaxRxQueue" }
    { "DWORD" "dwMaxBaud" }
    { "DWORD" "dwProvSubType" }
    { "DWORD" "dwProvCapabilities" }
    { "DWORD" "dwSettableParams" }
    { "DWORD" "dwSettableBaud" }
    { "WORD"  "wSettableData" }
    { "WORD"  "wSettableStopParity" }
    { "DWORD" "dwCurrentTxQueue" }
    { "DWORD" "dwCurrentRxQueue" }
    { "DWORD" "dwProvSpec1" }
    { "DWORD" "dwProvSpec2" }
    { { "WCHAR" 1 } "wcProvChar" } ;
TYPEDEF: COMMPROP* LPCOMMPROP


CONSTANT: SE_CREATE_TOKEN_NAME "SeCreateTokenPrivilege"
CONSTANT: SE_ASSIGNPRIMARYTOKEN_NAME "SeAssignPrimaryTokenPrivilege"
CONSTANT: SE_LOCK_MEMORY_NAME "SeLockMemoryPrivilege"
CONSTANT: SE_INCREASE_QUOTA_NAME "SeIncreaseQuotaPrivilege"
CONSTANT: SE_UNSOLICITED_INPUT_NAME "SeUnsolicitedInputPrivilege"
CONSTANT: SE_MACHINE_ACCOUNT_NAME "SeMachineAccountPrivilege"
CONSTANT: SE_TCB_NAME "SeTcbPrivilege"
CONSTANT: SE_SECURITY_NAME "SeSecurityPrivilege"
CONSTANT: SE_TAKE_OWNERSHIP_NAME "SeTakeOwnershipPrivilege"
CONSTANT: SE_LOAD_DRIVER_NAME "SeLoadDriverPrivilege"
CONSTANT: SE_SYSTEM_PROFILE_NAME "SeSystemProfilePrivilege"
CONSTANT: SE_SYSTEMTIME_NAME "SeSystemtimePrivilege"
CONSTANT: SE_PROF_SINGLE_PROCESS_NAME "SeProfileSingleProcessPrivilege"
CONSTANT: SE_INC_BASE_PRIORITY_NAME "SeIncreaseBasePriorityPrivilege"
CONSTANT: SE_CREATE_PAGEFILE_NAME "SeCreatePagefilePrivilege"
CONSTANT: SE_CREATE_PERMANENT_NAME "SeCreatePermanentPrivilege"
CONSTANT: SE_BACKUP_NAME "SeBackupPrivilege"
CONSTANT: SE_RESTORE_NAME "SeRestorePrivilege"
CONSTANT: SE_SHUTDOWN_NAME "SeShutdownPrivilege"
CONSTANT: SE_DEBUG_NAME "SeDebugPrivilege"
CONSTANT: SE_AUDIT_NAME "SeAuditPrivilege"
CONSTANT: SE_SYSTEM_ENVIRONMENT_NAME "SeSystemEnvironmentPrivilege"
CONSTANT: SE_CHANGE_NOTIFY_NAME "SeChangeNotifyPrivilege"
CONSTANT: SE_REMOTE_SHUTDOWN_NAME "SeRemoteShutdownPrivilege"
CONSTANT: SE_UNDOCK_NAME "SeUndockPrivilege"
CONSTANT: SE_ENABLE_DELEGATION_NAME "SeEnableDelegationPrivilege"
CONSTANT: SE_MANAGE_VOLUME_NAME "SeManageVolumePrivilege"
CONSTANT: SE_IMPERSONATE_NAME "SeImpersonatePrivilege"
CONSTANT: SE_CREATE_GLOBAL_NAME "SeCreateGlobalPrivilege"

CONSTANT: SE_GROUP_MANDATORY HEX: 00000001
CONSTANT: SE_GROUP_ENABLED_BY_DEFAULT HEX: 00000002
CONSTANT: SE_GROUP_ENABLED HEX: 00000004
CONSTANT: SE_GROUP_OWNER HEX: 00000008
CONSTANT: SE_GROUP_USE_FOR_DENY_ONLY HEX: 00000010
CONSTANT: SE_GROUP_LOGON_ID HEX: C0000000
CONSTANT: SE_GROUP_RESOURCE HEX: 20000000

CONSTANT: SE_PRIVILEGE_ENABLED_BY_DEFAULT HEX: 00000001
CONSTANT: SE_PRIVILEGE_ENABLED HEX: 00000002
CONSTANT: SE_PRIVILEGE_REMOVE HEX: 00000004
CONSTANT: SE_PRIVILEGE_USED_FOR_ACCESS HEX: 80000000

CONSTANT: PRIVILEGE_SET_ALL_NECESSARY 1

CONSTANT: SE_OWNER_DEFAULTED HEX: 00000001
CONSTANT: SE_GROUP_DEFAULTED HEX: 00000002
CONSTANT: SE_DACL_PRESENT HEX: 00000004
CONSTANT: SE_DACL_DEFAULTED HEX: 00000008
CONSTANT: SE_SACL_PRESENT HEX: 00000010
CONSTANT: SE_SACL_DEFAULTED HEX: 00000020
CONSTANT: SE_DACL_AUTO_INHERIT_REQ HEX: 00000100
CONSTANT: SE_SACL_AUTO_INHERIT_REQ HEX: 00000200
CONSTANT: SE_DACL_AUTO_INHERITED HEX: 00000400
CONSTANT: SE_SACL_AUTO_INHERITED HEX: 00000800
CONSTANT: SE_DACL_PROTECTED  HEX: 00001000
CONSTANT: SE_SACL_PROTECTED  HEX: 00002000
CONSTANT: SE_SELF_RELATIVE HEX: 00008000

CONSTANT: ANYSIZE_ARRAY 1

CONSTANT: MAXIMUM_WAIT_OBJECTS 64
CONSTANT: MAXIMUM_SUSPEND_COUNT HEX: 7f
CONSTANT: WAIT_OBJECT_0 0
CONSTANT: WAIT_ABANDONED_0 128
CONSTANT: WAIT_TIMEOUT 258
CONSTANT: WAIT_IO_COMPLETION HEX: c0
CONSTANT: WAIT_FAILED HEX: ffffffff

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

CONSTANT: OFS_MAXPATHNAME 128

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

CONSTANT: HANDLE_FLAG_INHERIT 1
CONSTANT: HANDLE_FLAG_PROTECT_FROM_CLOSE 2

CONSTANT: STARTF_USESHOWWINDOW    HEX: 00000001
CONSTANT: STARTF_USESIZE          HEX: 00000002
CONSTANT: STARTF_USEPOSITION      HEX: 00000004
CONSTANT: STARTF_USECOUNTCHARS    HEX: 00000008
CONSTANT: STARTF_USEFILLATTRIBUTE HEX: 00000010
CONSTANT: STARTF_RUNFULLSCREEN    HEX: 00000020
CONSTANT: STARTF_FORCEONFEEDBACK  HEX: 00000040
CONSTANT: STARTF_FORCEOFFFEEDBACK HEX: 00000080
CONSTANT: STARTF_USESTDHANDLES    HEX: 00000100
CONSTANT: STARTF_USEHOTKEY        HEX: 00000200

CONSTANT: PIPE_ACCESS_INBOUND  1
CONSTANT: PIPE_ACCESS_OUTBOUND 2
CONSTANT: PIPE_ACCESS_DUPLEX   3

CONSTANT: PIPE_TYPE_BYTE    0
CONSTANT: PIPE_TYPE_MESSAGE 4

CONSTANT: PIPE_READMODE_BYTE    0
CONSTANT: PIPE_READMODE_MESSAGE 2

CONSTANT: PIPE_WAIT   0
CONSTANT: PIPE_NOWAIT 1

CONSTANT: PIPE_UNLIMITED_INSTANCES 255

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
FUNCTION: BOOL AllocConsole ( ) ;
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
FUNCTION: BOOL CopyFileW ( LPCTSTR lpExistingFileName, LPCTSTR lpNewFileName, BOOL bFailIfExists ) ;
ALIAS: CopyFile CopyFileW
! FUNCTION: CopyLZFile
! FUNCTION: CreateActCtxA
! FUNCTION: CreateActCtxW
! FUNCTION: CreateConsoleScreenBuffer
! FUNCTION: CreateDirectoryA
! FUNCTION: CreateDirectoryExA
! FUNCTION: CreateDirectoryExW
FUNCTION: BOOL CreateDirectoryW ( LPCTSTR lpPathName, LPSECURITY_ATTRIBUTES lpSecurityAttribytes ) ;
ALIAS: CreateDirectory CreateDirectoryW

! FUNCTION: CreateEventA
! FUNCTION: CreateEventW
! FUNCTION: CreateFiber
! FUNCTION: CreateFiberEx


FUNCTION: HANDLE CreateFileW ( LPCTSTR lpFileName, DWORD dwDesiredAccess, DWORD dwShareMode, LPSECURITY_ATTRIBUTES lpSecurityAttribures, DWORD dwCreationDisposition, DWORD dwFlagsAndAttributes, HANDLE hTemplateFile ) ;
ALIAS: CreateFile CreateFileW

FUNCTION: HANDLE  CreateFileMappingW ( HANDLE hFile,
                                       LPSECURITY_ATTRIBUTES lpAttributes,
                                       DWORD flProtect,
                                       DWORD dwMaximumSizeHigh,
                                       DWORD dwMaximumSizeLow,
                                       LPCTSTR lpName ) ;
ALIAS: CreateFileMapping CreateFileMappingW

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
ALIAS: CreateNamedPipe CreateNamedPipeW

! FUNCTION: CreateNlsSecurityDescriptor
FUNCTION: BOOL CreatePipe ( PHANDLE hReadPipe, PHANDLE hWritePipe, LPSECURITY_ATTRIBUTES lpPipeAttributes, DWORD nSize ) ;

CONSTANT: DEBUG_PROCESS                   HEX: 00000001
CONSTANT: DEBUG_ONLY_THIS_PROCESS         HEX: 00000002
CONSTANT: CREATE_SUSPENDED                HEX: 00000004
CONSTANT: DETACHED_PROCESS                HEX: 00000008
CONSTANT: CREATE_NEW_CONSOLE              HEX: 00000010
CONSTANT: NORMAL_PRIORITY_CLASS           HEX: 00000020
CONSTANT: IDLE_PRIORITY_CLASS             HEX: 00000040
CONSTANT: HIGH_PRIORITY_CLASS             HEX: 00000080
CONSTANT: REALTIME_PRIORITY_CLASS         HEX: 00000100
CONSTANT: CREATE_NEW_PROCESS_GROUP        HEX: 00000200
CONSTANT: CREATE_UNICODE_ENVIRONMENT      HEX: 00000400
CONSTANT: CREATE_SEPARATE_WOW_VDM         HEX: 00000800
CONSTANT: CREATE_SHARED_WOW_VDM           HEX: 00001000
CONSTANT: CREATE_FORCEDOS                 HEX: 00002000
CONSTANT: BELOW_NORMAL_PRIORITY_CLASS     HEX: 00004000
CONSTANT: ABOVE_NORMAL_PRIORITY_CLASS     HEX: 00008000
CONSTANT: CREATE_BREAKAWAY_FROM_JOB       HEX: 01000000
CONSTANT: CREATE_WITH_USERPROFILE         HEX: 02000000
CONSTANT: CREATE_DEFAULT_ERROR_MODE       HEX: 04000000
CONSTANT: CREATE_NO_WINDOW                HEX: 08000000
CONSTANT: PROFILE_USER                    HEX: 10000000
CONSTANT: PROFILE_KERNEL                  HEX: 20000000
CONSTANT: PROFILE_SERVER                  HEX: 40000000

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
ALIAS: CreateProcess CreateProcessW
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
ALIAS: DeleteFile DeleteFileW
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

FUNCTION: BOOL DuplicateHandle (
    HANDLE hSourceProcessHandle,
    HANDLE hSourceHandle,
    HANDLE hTargetProcessHandle,
    LPHANDLE lpTargetHandle,
    DWORD dwDesiredAccess,
    BOOL bInheritHandle,
    DWORD dwOptions ) ;

CONSTANT: DUPLICATE_CLOSE_SOURCE 1
CONSTANT: DUPLICATE_SAME_ACCESS 2

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
ALIAS: FindFirstChangeNotification FindFirstChangeNotificationW
! FUNCTION: FindFirstFileA
! FUNCTION: FindFirstFileExA
! FUNCTION: FindFirstFileExW
FUNCTION: HANDLE FindFirstFileW ( LPCTSTR lpFileName, LPWIN32_FIND_DATA lpFindFileData ) ;
ALIAS: FindFirstFile FindFirstFileW
! FUNCTION: FindFirstVolumeA
! FUNCTION: FindFirstVolumeMountPointA

FUNCTION: HANDLE FindFirstVolumeMountPointW (
    LPTSTR lpszRootPathName,
    LPTSTR lpszVolumeMountPoint,
    DWORD cchBufferLength
) ;
ALIAS: FindFirstVolumeMountPoint FindFirstVolumeMountPointW

FUNCTION: HANDLE FindFirstVolumeW ( LPTSTR lpszVolumeName, DWORD cchBufferLength ) ;
ALIAS: FindFirstVolume FindFirstVolumeW

FUNCTION: BOOL FindNextChangeNotification ( HANDLE hChangeHandle ) ;

! FUNCTION: FindNextFileA
FUNCTION: BOOL FindNextFileW ( HANDLE hFindFile, LPWIN32_FIND_DATA lpFindFileData ) ;
ALIAS: FindNextFile FindNextFileW

! FUNCTION: FindNextVolumeA
! FUNCTION: FindNextVolumeMountPointA

FUNCTION: BOOL FindNextVolumeMountPointW (
    HANDLE hFindVolumeMountPoint,
    LPTSTR lpszVolumeMountPoint,
    DWORD cchBufferLength
) ;
ALIAS: FindNextVolumeMountPoint FindNextVolumeMountPointW

FUNCTION: BOOL FindNextVolumeW ( HANDLE hFindVolume, LPTSTR lpszVolumeName, DWORD cchBufferLength ) ;
ALIAS: FindNextVolume FindNextVolumeW

! FUNCTION: FindResourceA
! FUNCTION: FindResourceExA
! FUNCTION: FindResourceExW
! FUNCTION: FindResourceW
FUNCTION: BOOL FindVolumeClose ( HANDLE hFindVolume ) ;
FUNCTION: BOOL FindVolumeMountPointClose ( HANDLE hFindVolumeMountPoint ) ;
! FUNCTION: FlushConsoleInputBuffer
! FUNCTION: FlushFileBuffers
! FUNCTION: FlushInstructionCache
! FUNCTION: FlushViewOfFile
! FUNCTION: FoldStringA
! FUNCTION: FoldStringW
! FUNCTION: FormatMessageA
! FUNCTION: FormatMessageW
FUNCTION: BOOL FreeConsole ( ) ;
! FUNCTION: FreeEnvironmentStringsA
FUNCTION: BOOL FreeEnvironmentStringsW ( LPTCH lpszEnvironmentBlock ) ;
ALIAS: FreeEnvironmentStrings FreeEnvironmentStringsW
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
FUNCTION: BOOL GetCommConfig ( HANDLE hCommDev, LPCOMMCONFIG lpCC, LPDWORD lpdwSize ) ;
FUNCTION: BOOL GetCommMask ( HANDLE hFile, LPDWORD lpEvtMask ) ;
FUNCTION: BOOL GetCommModemStatus ( HANDLE hFile, LPDWORD lpModemStat ) ;
FUNCTION: BOOL GetCommProperties ( HANDLE hFile, LPCOMMPROP lpCommProp ) ;
FUNCTION: BOOL GetCommState ( HANDLE hFile, LPDCB lpDCB ) ;
! FUNCTION: GetCommTimeouts
! FUNCTION: GetComPlusPackageInstallStatus
! FUNCTION: GetCompressedFileSizeA
! FUNCTION: GetCompressedFileSizeW
FUNCTION: BOOL GetComputerNameW ( LPTSTR lpBuffer, LPDWORD lpnSize ) ;
ALIAS: GetComputerName GetComputerNameW
FUNCTION: BOOL GetComputerNameExW ( COMPUTER_NAME_FORMAT NameType, LPTSTR lpBuffer, LPDWORD lpnSize ) ;
ALIAS: GetComputerNameEx GetComputerNameExW
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
ALIAS: GetConsoleTitle GetConsoleTitleW
FUNCTION: HWND GetConsoleWindow ( ) ;
! FUNCTION: GetCPFileNameFromRegistry
! FUNCTION: GetCPInfo
! FUNCTION: GetCPInfoExA
! FUNCTION: GetCPInfoExW
! FUNCTION: GetCurrencyFormatA
! FUNCTION: GetCurrencyFormatW
! FUNCTION: GetCurrentActCtx
! FUNCTION: GetCurrentConsoleFont
! FUNCTION: GetCurrentDirectoryA
FUNCTION: BOOL GetCurrentDirectoryW ( DWORD len, LPTSTR buf ) ;
ALIAS: GetCurrentDirectory GetCurrentDirectoryW
FUNCTION: HANDLE GetCurrentProcess ( ) ;
FUNCTION: DWORD GetCurrentProcessId ( ) ;
FUNCTION: HANDLE GetCurrentThread ( ) ;
! FUNCTION: GetCurrentThreadId
! FUNCTION: GetDateFormatA
! FUNCTION: GetDateFormatW
! FUNCTION: GetDefaultCommConfigA
FUNCTION: BOOL GetDefaultCommConfigW ( LPCTSTR lpszName, LPCOMMCONFIG lpCC, LPDWORD lpdwSize ) ;
ALIAS: GetDefaultCommConfig GetDefaultCommConfigW
! FUNCTION: GetDefaultSortkeySize
! FUNCTION: GetDevicePowerState
! FUNCTION: GetDiskFreeSpaceA
! FUNCTION: GetDiskFreeSpaceExA
FUNCTION: BOOL GetDiskFreeSpaceExW ( LPCTSTR lpDirectoryName, PULARGE_INTEGER pFreeBytesAvailable, PULARGE_INTEGER lpTotalNumberOfBytes, PULARGE_INTEGER lpTotalNumberOfFreeBytes ) ;
ALIAS: GetDiskFreeSpaceEx GetDiskFreeSpaceExW
! FUNCTION: GetDiskFreeSpaceW
! FUNCTION: GetDllDirectoryA
! FUNCTION: GetDllDirectoryW
! FUNCTION: GetDriveTypeA
FUNCTION: UINT GetDriveTypeW ( LPCTSTR lpRootPathName ) ;
ALIAS: GetDriveType GetDriveTypeW
FUNCTION: void* GetEnvironmentStringsW ( ) ;
! FUNCTION: GetEnvironmentStringsA
ALIAS: GetEnvironmentStrings GetEnvironmentStringsW
! FUNCTION: GetEnvironmentVariableA
FUNCTION: DWORD GetEnvironmentVariableW ( LPCTSTR lpName, LPTSTR lpBuffer, DWORD nSize ) ;
ALIAS: GetEnvironmentVariable GetEnvironmentVariableW
FUNCTION: BOOL GetExitCodeProcess ( HANDLE hProcess, LPDWORD lpExitCode ) ;
! FUNCTION: GetExitCodeThread
! FUNCTION: GetExpandedNameA
! FUNCTION: GetExpandedNameW
! FUNCTION: GetFileAttributesA
FUNCTION: DWORD GetFileAttributesW ( LPCTSTR lpFileName ) ;
! FUNCTION: GetFileAttributesExA

CONSTANT: GetFileExInfoStandard 0


FUNCTION: BOOL GetFileAttributesExW ( LPCTSTR lpFileName, GET_FILEEX_INFO_LEVELS fInfoLevelId, LPVOID lpFileInformation ) ;

ALIAS: GetFileAttributesEx GetFileAttributesExW

FUNCTION: BOOL GetFileInformationByHandle ( HANDLE hFile, LPBY_HANDLE_FILE_INFORMATION lpFileInformation ) ;
FUNCTION: DWORD GetFileSize ( HANDLE hFile, LPDWORD lpFileSizeHigh ) ;
FUNCTION: BOOL GetFileSizeEx ( HANDLE hFile, PLARGE_INTEGER lpFileSize ) ;
FUNCTION: BOOL GetFileTime ( HANDLE hFile, LPFILETIME lpCreationTime, LPFILETIME lpLastAccessTime, LPFILETIME lpLastWriteTime ) ;
FUNCTION: DWORD GetFileType ( HANDLE hFile ) ;
! FUNCTION: GetFirmwareEnvironmentVariableA
! FUNCTION: GetFirmwareEnvironmentVariableW
! FUNCTION: GetFullPathNameA
FUNCTION: DWORD GetFullPathNameW ( LPCTSTR lpFileName, DWORD nBufferLength, LPTSTR lpBuffer, LPTSTR* lpFilePart ) ;
ALIAS: GetFullPathName GetFullPathNameW

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
FUNCTION: DWORD GetLogicalDrives ( ) ;
! FUNCTION: GetLogicalDriveStringsA
! FUNCTION: GetLogicalDriveStringsW
! FUNCTION: GetLongPathNameA
! FUNCTION: GetLongPathNameW
! FUNCTION: GetMailslotInfo
! FUNCTION: GetModuleFileNameA
! FUNCTION: GetModuleFileNameW
FUNCTION: HMODULE GetModuleHandleW ( LPCWSTR lpModuleName ) ;
ALIAS: GetModuleHandle GetModuleHandleW
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
FUNCTION: DWORD GetPriorityClass ( HANDLE hProcess ) ;
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
FUNCTION: UINT GetSystemDirectoryW ( LPTSTR lpBuffer, UINT uSize ) ;
ALIAS: GetSystemDirectory GetSystemDirectoryW
FUNCTION: void GetSystemInfo ( LPSYSTEM_INFO lpSystemInfo ) ;
! FUNCTION: GetSystemPowerStatus
! FUNCTION: GetSystemRegistryQuota
FUNCTION: void GetSystemTime ( LPSYSTEMTIME lpSystemTime ) ;
! FUNCTION: GetSystemTimeAdjustment
FUNCTION: void GetSystemTimeAsFileTime ( LPFILETIME lpSystemTimeAsFileTime ) ;
! FUNCTION: GetSystemTimes
! FUNCTION: GetSystemWindowsDirectoryA
FUNCTION: UINT GetSystemWindowsDirectoryW ( LPTSTR lpBuffer, UINT uSize ) ;
ALIAS: GetSystemWindowsDirectory GetSystemWindowsDirectoryW
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
FUNCTION: int GetThreadPriority ( HANDLE hThread ) ;
FUNCTION: BOOL GetThreadPriorityBoost ( HANDLE hThread, PBOOL pDisablePriorityBoost ) ;
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
ALIAS: GetVersionEx GetVersionExW
! FUNCTION: GetVolumeInformationA
FUNCTION: BOOL GetVolumeInformationW (
    LPCTSTR lpRootPathName,
    LPTSTR lpVolumNameBuffer,
    DWORD nVolumeNameSize,
    LPDWORD lpVolumeSerialNumber,
    LPDWORD lpMaximumComponentLength,
    LPDWORD lpFileSystemFlags,
    LPCTSTR lpFileSystemNameBuffer,
    DWORD nFileSystemNameSize
) ;
ALIAS: GetVolumeInformation GetVolumeInformationW
! FUNCTION: GetVolumeNameForVolumeMountPointA
! FUNCTION: GetVolumeNameForVolumeMountPointW
! FUNCTION: GetVolumePathNameA
! FUNCTION: GetVolumePathNamesForVolumeNameA
FUNCTION: BOOL GetVolumePathNamesForVolumeNameW ( LPCTSTR lpszVolumeName, LPTSTR lpszVolumePathNames, DWORD cchBufferLength, PDWORD lpcchReturnLength ) ;
ALIAS: GetVolumePathNamesForVolumeName GetVolumePathNamesForVolumeNameW

! FUNCTION: GetVolumePathNameW
! FUNCTION: GetWindowsDirectoryA
FUNCTION: UINT GetWindowsDirectoryW ( LPTSTR lpBuffer, UINT uSize ) ;
ALIAS: GetWindowsDirectory GetWindowsDirectoryW
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
FUNCTION: HMODULE LoadLibraryExW ( LPCTSTR lpFile, HANDLE hFile, DWORD flags ) ;
ALIAS: LoadLibraryEx LoadLibraryExW
! FUNCTION: LoadLibraryW
! FUNCTION: LoadModule
! FUNCTION: LoadResource
FUNCTION: HLOCAL LocalAlloc ( UINT uFlags, SIZE_T uBytes ) ;
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
ALIAS: MoveFile MoveFileW
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
ALIAS: OpenFileMapping OpenFileMappingW
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
ALIAS: RemoveDirectory RemoveDirectoryW
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
FUNCTION: BOOL SetCommBreak ( HANDLE hFile ) ;
FUNCTION: BOOL SetCommConfig ( HANDLE hCommDev, LPCOMMCONFIG lpCC, DWORD dwSize ) ;
FUNCTION: BOOL SetCommMask ( HANDLE hFile, DWORD dwEvtMask ) ;
FUNCTION: BOOL SetCommState ( HANDLE hFile, LPDCB lpDCB ) ;
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
ALIAS: SetConsoleTitle SetConsoleTitleW
! FUNCTION: SetConsoleWindowInfo
! FUNCTION: SetCPGlobal
! FUNCTION: SetCriticalSectionSpinCount
! FUNCTION: SetCurrentDirectoryA
FUNCTION: BOOL SetCurrentDirectoryW ( LPCWSTR lpDirectory ) ;
ALIAS: SetCurrentDirectory SetCurrentDirectoryW
! FUNCTION: SetDefaultCommConfigA
FUNCTION: BOOL SetDefaultCommConfigW ( LPCTSTR lpszName, LPCOMMCONFIG lpCC, LPDWORD lpdwSize ) ;
ALIAS: SetDefaultCommConfig SetDefaultCommConfigW
! FUNCTION: SetDllDirectoryA
! FUNCTION: SetDllDirectoryW
FUNCTION: BOOL SetEndOfFile ( HANDLE hFile ) ;
! FUNCTION: SetEnvironmentVariableA
FUNCTION: BOOL SetEnvironmentVariableW ( LPCTSTR key, LPCTSTR value ) ;
ALIAS: SetEnvironmentVariable SetEnvironmentVariableW
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
FUNCTION: BOOL SetPriorityClass ( HANDLE hProcess, DWORD dwPriorityClass ) ;
! FUNCTION: SetProcessAffinityMask
FUNCTION: BOOL SetProcessPriorityBoost ( HANDLE hProcess, BOOL disablePriorityBoost ) ;
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
FUNCTION: BOOL SetThreadPriority ( HANDLE hThread, int nPriority ) ;
FUNCTION: BOOL SetThreadPriorityBoost ( HANDLE hThread, BOOL disablePriorityBoost ) ;
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
FUNCTION: BOOL TerminateProcess ( HANDLE hProcess, DWORD uExit ) ;
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
FUNCTION: DWORD WaitForMultipleObjects ( DWORD nCount, HANDLE* lpHandles, BOOL bWaitAll, DWORD dwMilliseconds ) ;
! FUNCTION: WaitForMultipleObjectsEx
FUNCTION: BOOL WaitForSingleObject ( HANDLE hHandle, DWORD dwMilliseconds ) ;
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

: with-global-lock ( HGLOBAL quot -- )
    swap [ GlobalLock swap call ] keep GlobalUnlock drop ; inline
