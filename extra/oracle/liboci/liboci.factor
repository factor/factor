! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Adapted from oci.h and ociap.h
! Tested with Oracle version - 10.1.0.3 Instant Client
!
! DYLD_LIBRARY_PATH="/usr/local/oracle/instantclient10_1"
! export DYLD_LIBRARY_PATH

USING: alien alien.syntax combinators kernel system ;

IN: oracle.liboci

"oci" {
    { [ win32? ] [ "oci.dll" "stdcall" ] }
    { [ macosx? ] [ "$DYLD_LIBRARY_PATH/libclntsh.dylib" "cdecl" ] }
    { [ unix? ] [ "$DYLD_LIBRARY_PATH/libclntsh.so.10.1" "cdecl" ] }
} cond add-library

! ===============================================
! Attribute Types
! ===============================================

: OCI_ATTR_USERNAME 22  ; inline ! username attribute
: OCI_ATTR_PASSWORD 23  ; inline ! password attribute

! ===============================================
! Various Modes
! ===============================================

: OCI_DEFAULT   HEX: 00 ; inline ! default value for parameters and attributes
: OCI_THREADED  HEX: 01 ; inline ! appl. in threaded environment
: OCI_OBJECT    HEX: 02 ; inline ! application in object environment

! ===============================================
! Execution Modes
! ===============================================

: OCI_DESCRIBE_ONLY   HEX: 10 ; inline ! only describe the statement

! ===============================================
! Credential Types
! ===============================================

: OCI_CRED_RDBMS      1 ; inline ! database username/password
: OCI_CRED_EXT        2 ; inline ! externally provided credentials
: OCI_CRED_PROXY      3 ; inline ! proxy authentication

! ===============================================
! Error Return Values
! ===============================================

: OCI_SUCCESS               0     ; inline ! maps to SQL_SUCCESS of SAG CLI
: OCI_SUCCESS_WITH_INFO     1     ; inline ! maps to SQL_SUCCESS_WITH_INFO
: OCI_RESERVED_FOR_INT_USE  200   ; inline ! reserved
: OCI_NO_DATA               100   ; inline ! maps to SQL_NO_DATA
: OCI_ERROR                 -1    ; inline ! maps to SQL_ERROR
: OCI_INVALID_HANDLE        -2    ; inline ! maps to SQL_INVALID_HANDLE
: OCI_NEED_DATA             99    ; inline ! maps to SQL_NEED_DATA
: OCI_STILL_EXECUTING       -3123 ; inline ! OCI would block error

! ===============================================
! Parsing Syntax Types
! ===============================================

: OCI_V7_SYNTAX            2 ; inline ! V815 language - for backwards compatibility
: OCI_V8_SYNTAX            3 ; inline ! V815 language - for backwards compatibility
: OCI_NTV_SYNTAX           1 ; inline ! Use what so ever is the native lang of server

! ===============================================
! Scrollable Cursor Fetch Options
! For non-scrollable cursor, the only valid
! (and default) orientation is OCI_FETCH_NEXT
! ===============================================

: OCI_FETCH_CURRENT       HEX: 01 ; inline ! refetching current position
: OCI_FETCH_NEXT          HEX: 02 ; inline ! next row
: OCI_FETCH_FIRST         HEX: 04 ; inline ! first row of the result set
: OCI_FETCH_LAST          HEX: 08 ; inline ! the last row of the result set
: OCI_FETCH_PRIOR         HEX: 10 ; inline ! the previous row relative to current
: OCI_FETCH_ABSOLUTE      HEX: 20 ; inline ! absolute offset from first
: OCI_FETCH_RELATIVE      HEX: 40 ; inline ! offset relative to current
: OCI_FETCH_RESERVED_1    HEX: 80 ; inline ! reserved

! ===============================================
! Handle Types
! ===============================================

: OCI_HTYPE_ENV            1  ; inline ! environment handle
: OCI_HTYPE_ERROR          2  ; inline ! error handle
: OCI_HTYPE_SVCCTX         3  ; inline ! service handle
: OCI_HTYPE_STMT           4  ; inline ! statement handle
: OCI_HTYPE_BIND           5  ; inline ! bind handle
: OCI_HTYPE_DEFINE         6  ; inline ! define handle
: OCI_HTYPE_DESCRIBE       7  ; inline ! describe handle
: OCI_HTYPE_SERVER         8  ; inline ! server handle
: OCI_HTYPE_SESSION        9  ; inline ! authentication handle

! ===============================================
! Attribute Types
! ===============================================

: OCI_ATTR_FNCODE                   1  ; inline ! the OCI function code
: OCI_ATTR_OBJECT                   2  ; inline ! is the environment initialized in object mode
: OCI_ATTR_NONBLOCKING_MODE         3  ; inline ! non blocking mode
: OCI_ATTR_SQLCODE                  4  ; inline ! the SQL verb
: OCI_ATTR_ENV                      5  ; inline ! the environment handle
: OCI_ATTR_SERVER                   6  ; inline ! the server handle
: OCI_ATTR_SESSION                  7  ; inline ! the user session handle
: OCI_ATTR_TRANS                    8  ; inline ! the transaction handle
: OCI_ATTR_ROW_COUNT                9  ; inline ! the rows processed so far
: OCI_ATTR_SQLFNCODE                10 ; inline ! the SQL verb of the statement
: OCI_ATTR_PREFETCH_ROWS            11 ; inline ! sets the number of rows to prefetch
: OCI_ATTR_NESTED_PREFETCH_ROWS     12 ; inline ! the prefetch rows of nested table
: OCI_ATTR_PREFETCH_MEMORY          13 ; inline ! memory limit for rows fetched
: OCI_ATTR_NESTED_PREFETCH_MEMORY   14 ; inline ! memory limit for nested rows
: OCI_ATTR_CHAR_COUNT               15 ; inline ! this specifies the bind and define size in characters

! ===============================================
! OCI integer types
! ===============================================

TYPEDEF: ushort ub2
TYPEDEF: short sb2
TYPEDEF: uint ub4
TYPEDEF: int sb4
TYPEDEF: ulong size_t

! ===============================================
! Input data types (ocidfn.h)
! ===============================================

: SQLT_CHR                  1    ; inline ! (ORANET TYPE) character string
: SQLT_NUM                  2    ; inline ! (ORANET TYPE) oracle numeric
: SQLT_INT                  3    ; inline ! (ORANET TYPE) integer
: SQLT_FLT                  4    ; inline ! (ORANET TYPE) Floating point number
: SQLT_STR                  5    ; inline ! zero terminated string
: SQLT_ODT                  156  ; inline ! OCIDate type

! ===============================================
! Input datetimes and intervals (ocidfn.h)
! ===============================================

: SQLT_DATE                184   ; inline ! ANSI Date
: SQLT_TIME                185   ; inline ! TIME
: SQLT_TIME_TZ             186   ; inline ! TIME WITH TIME ZONE
: SQLT_TIMESTAMP           187   ; inline ! TIMESTAMP
: SQLT_TIMESTAMP_TZ        188   ; inline ! TIMESTAMP WITH TIME ZONE
: SQLT_INTERVAL_YM         189   ; inline ! INTERVAL YEAR TO MONTH
: SQLT_INTERVAL_DS         190   ; inline ! INTERVAL DAY TO SECOND
: SQLT_TIMESTAMP_LTZ       232   ; inline ! TIMESTAMP WITH LOCAL TZ

! ===============================================
! Opaque pointer types
! ===============================================

TYPEDEF: void dvoid
TYPEDEF: void oci_env
TYPEDEF: void oci_server
TYPEDEF: void oci_error
TYPEDEF: void oci_svc_ctx
TYPEDEF: void oci_session
TYPEDEF: void oci_stmt

LIBRARY: oci

! ===============================================
! ociap.h
! ===============================================

FUNCTION: int OCIInitialize ( ub4 mode, void* ctxp, void* malocfp, void* ralocfp, dvoid* mfreefp ) ;
FUNCTION: int OCITerminate ( ub4 mode ) ;
FUNCTION: int OCIEnvInit ( void* envhpp, ub4 mode, size_t xtramem_sz, dvoid* usrmempp ) ;
FUNCTION: int OCIEnvCreate ( dvoid* envhpp, ub4 mode, void* ctxp, void* malocfp, void* ralocfp, void* mfreefp, size_t xtramemz, dvoid* usrmempp ) ;
FUNCTION: int OCIHandleAlloc ( void* parenth, dvoid* hndlpp, ub4 type, size_t xtramem_sz, dvoid* usrmempp ) ;
FUNCTION: int OCIServerAttach ( void* srvhp, void* errhp, char* dblink, sb4 dblink_len, ub4 mode ) ;
FUNCTION: int OCIServerDetach ( void* srvhp, void* errhp, ub4 mode ) ;
FUNCTION: int OCIHandleFree ( dvoid* p0, ub4 p1 ) ;
FUNCTION: int OCILogon ( void* envhp, void* errhp, dvoid* svchpp, uchar* username, ub4 uname_len, uchar* passwd, ub4 password_len, uchar* dsn, ub4 dsn_len ) ;
FUNCTION: int OCILogoff ( void* p0, void* p1 ) ;
FUNCTION: void OCIErrorGet ( void* handlp, ub4 recordno, char* sqlstate, sb4* errcodep, uchar* bufp, ub4 bufsize, ub4 type ) ;
FUNCTION: int OCIStmtPrepare ( void* stmtp, void* errhp, uchar* stmt, ub4 stmt_len, ub4 language, ub4 mode ) ;
FUNCTION: int OCIStmtExecute ( void* svchp, void* stmtp1, void* errhp, ub4 iters, ub4 rowoff, void* snap_in, void* snap_out, ub4 mode ) ;
FUNCTION: int OCIParamGet ( void* hndlp, ub4 htype, void* errhp, dvoid* parmdpp, ub4 pos ) ;
FUNCTION: int OCIAttrGet ( void* trgthndlp, ub4 trghndltyp, void* attributep, ub4* sizep, ub4 attrtype, void* errhp ) ;
FUNCTION: int OCIAttrSet ( dvoid* trgthndlp, ub4 trgthndltyp, dvoid* attributep, ub4 size, ub4 attrtype, oci_error* errhp ) ;
FUNCTION: int OCIDefineByPos ( void* stmtp, dvoid* defnpp, void* errhp, ub4 position, void* valuep, sb4 value_sz, ub2 dty, sb2* indp, ub2* rlenp, ub2* rcodep, ub4 mode ) ;
FUNCTION: int OCIStmtFetch ( void* stmthp, void* errhp, ub4 p2, ub2 p3, ub4 p4 ) ;
FUNCTION: int OCITransStart ( void* svchp, void* errhp, ushort p2, ushort p3 ) ;
FUNCTION: int OCITransCommit ( void* svchp, void* errhp, ushort p2 ) ;
FUNCTION: int OCITransRollback ( void* svchp, void* errhp, ushort p2 ) ;
FUNCTION: int OCISessionBegin ( oci_svc_ctx* svchp, oci_error* errhp,  oci_session* usrhp, ub4 credt, ub4 mode ) ;
FUNCTION: int OCISessionEnd ( oci_svc_ctx* svchp, oci_error* errhp,  oci_session* usrhp, ub4 mode ) ;
FUNCTION: int OCIServerVersion ( void* handlp, void* errhp, uchar* bufsz, int bufsz, short hndltype ) ;
