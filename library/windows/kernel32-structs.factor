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
    FIELD: SYSTEMTIME DaylightDate
    FIELD: LONG DaylightBias
END-STRUCT


BEGIN-STRUCT: FILETIME
    FIELD: DWORD dwLowDateTime
    FIELD: DWORD dwHighDateTime
END-STRUCT

