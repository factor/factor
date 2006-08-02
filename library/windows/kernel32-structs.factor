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

