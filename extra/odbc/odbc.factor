! Copyright (C) 2007 Chris Double, 2016 Alexander Ilin, 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.strings alien.syntax arrays calendar combinators
combinators.extras continuations endian generalizations
io.encodings.ascii io.encodings.string io.encodings.utf8 kernel
make math pack sequences sequences.generalizations strings
system threads vocabs.platforms ;
FROM: alien.c-types => float short ;
IN: odbc

<< "odbc" {
    { [ os macosx? ] [ "libiodbc.dylib" ] }
    { [ os unix? ] [ "libodbc.so" ] }
    { [ os windows? ] [ "odbc32.dll" ] }
} cond
stdcall add-library >>

LIBRARY: odbc

TYPEDEF: short SQLRETURN
TYPEDEF: short SQLSMALLINT
TYPEDEF: ushort SQLUSMALLINT
TYPEDEF: uint SQLUINTEGER
TYPEDEF: int SQLINTEGER
TYPEDEF: char SQLCHAR
TYPEDEF: void* SQLHANDLE
TYPEDEF: void* SQLHENV
TYPEDEF: void* SQLHDBC
TYPEDEF: void* SQLHSTMT
TYPEDEF: void* SQLHWND
TYPEDEF: void* SQLPOINTER
TYPEDEF: void* SQLHDESC

<32
TYPEDEF: long SQLLEN
TYPEDEF: ulong SQLULEN
TYPEDEF: long SQLBIGINT
TYPEDEF: ulong SQLUBIGINT
32>

<64
TYPEDEF: longlong SQLLEN
TYPEDEF: ulonglong SQLULEN
TYPEDEF: longlong SQLBIGINT
TYPEDEF: ulonglong SQLUBIGINT
64>

CONSTANT: SQL-HANDLE-ENV  1
CONSTANT: SQL-HANDLE-DBC  2
CONSTANT: SQL-HANDLE-STMT 3
CONSTANT: SQL-HANDLE-DESC 4

CONSTANT: SQL-NULL-HANDLE f

CONSTANT: SQL_MAX_MESSAGE_LENGTH 512

CONSTANT: SQL_SQLSTATE_SIZE 5

CONSTANT: SQL-ATTR-ODBC-VERSION 200 ! ODBC 3.8

: SQL-OV-ODBC2 ( -- number ) 2 <alien> ; inline
: SQL-OV-ODBC3 ( -- number ) 3 <alien> ; inline

CONSTANT: SQL_HANDLE_ENV 1
CONSTANT: SQL_HANDLE_DBC 2
CONSTANT: SQL_HANDLE_STMT 3
CONSTANT: SQL_HANDLE_DESC 4

CONSTANT: SQL_NULL_HANDLE 0

CONSTANT: SQL_NTS -3

CONSTANT: SQL-DRIVER-NOPROMPT 0
CONSTANT: SQL-DRIVER-PROMPT 2

CONSTANT: SQL_COMMIT 0
CONSTANT: SQL_ROLLBACK 1

CONSTANT: SQL_ATTR_CONNECTION_TIMEOUT 113
CONSTANT: SQL_ATTR_QUERY_TIMEOUT 0

CONSTANT: SQL_FETCH_NEXT 1
CONSTANT: SQL_FETCH_FIRST 2
CONSTANT: SQL_FETCH_LAST 3
CONSTANT: SQL_FETCH_PRIOR 4
CONSTANT: SQL_FETCH_ABSOLUTE 5
CONSTANT: SQL_FETCH_RELATIVE 6
CONSTANT: SQL_FETCH_BOOKMARK 8

CONSTANT: SQL_CLOSE 0
CONSTANT: SQL_DROP 1
CONSTANT: SQL_UNBIND 2
CONSTANT: SQL_RESET_PARAMS 3

CONSTANT: SQL_ERROR -1
CONSTANT: SQL_SUCCESS 0
CONSTANT: SQL_SUCCESS_WITH_INFO 1
CONSTANT: SQL_INVALID_HANDLE -2
CONSTANT: SQL_NO_DATA 100

CONSTANT: SQL_NO_DATA_FOUND 100
CONSTANT: SQL-C-DEFAULT 99

SYMBOLS:
    SQL-CHAR SQL-VARCHAR SQL-LONGVARCHAR
    SQL-WCHAR SQL-WCHARVAR SQL-WLONGCHARVAR
    SQL-DECIMAL SQL-SMALLINT SQL-NUMERIC SQL-INTEGER
    SQL-REAL SQL-FLOAT SQL-DOUBLE
    SQL-BIT
    SQL-TINYINT SQL-BIGINT
    SQL-BINARY SQL-VARBINARY SQL-LONGVARBINARY
    SQL-TYPE-DATE SQL-TYPE-TIME SQL-TYPE-TIMESTAMP
    SQL-TYPE-UTCDATETIME SQL-TYPE-UTCTIME
    SQL-INTERVAL-MONTH SQL-INTERVAL-YEAR SQL-INTERVAL-DAY
    SQL-INTERVAL-HOUR SQL-INTERVAL-MINUTE SQL-INTERVAL-SECOND
    SQL-INTERVAL-YEAR-TO-MONTH
    SQL-INTERVAL-DAY-TO-HOUR SQL-INTERVAL-DAY-TO-MINUTE
    SQL-INTERVAL-DAY-TO-SECOND
    SQL-INTERVAL-HOUR-TO-MINUTE SQL-INTERVAL-HOUR-TO-SECOND SQL-INTERVAL-MINUTE-TO-SECOND
    SQL-GUID SQL-XML SQL-UDT SQL-GEOMETRY SQL-GEOMETRYCOLLECTION SQL-CIRCULARSTRING
    SQL-COMPOUNDCURVE SQL-CURVEPOLYGON SQL-FULLTEXT SQL-FULLTEXTKEY SQL-LINESTRING
    SQL-MULTILINESTRING SQL-MULTIPOINT SQL-MULTIPOLYGON SQL-POINT SQL-POLYGON
    SQL-TYPE-UNKNOWN ;

: convert-sql-type ( number -- symbol )
    {
        {   1 [ SQL-CHAR ] }
        {  12 [ SQL-VARCHAR ] }
        {  -1 [ SQL-LONGVARCHAR ] }
        {  -8 [ SQL-WCHAR ] }
        {  -9 [ SQL-WCHARVAR ] }
        { -10 [ SQL-WLONGCHARVAR ] }
        {   3 [ SQL-DECIMAL ] }
        {   5 [ SQL-SMALLINT ] }
        {   2 [ SQL-NUMERIC ] }
        {   4 [ SQL-INTEGER ] }
        {   7 [ SQL-REAL ] }
        {   6 [ SQL-FLOAT ] }
        {   8 [ SQL-DOUBLE ] }
        {  -7 [ SQL-BIT ] }
        {  -6 [ SQL-TINYINT ] }
        {  -5 [ SQL-BIGINT ] }
        {  -2 [ SQL-BINARY ] }
        {  -3 [ SQL-VARBINARY ] }
        {  -4 [ SQL-LONGVARBINARY ] }
        {  91 [ SQL-TYPE-DATE ] }
        {  92 [ SQL-TYPE-TIME ] }
        {  93 [ SQL-TYPE-TIMESTAMP ] }
        {  -151 [ SQL-XML ] }
        {  -152 [ SQL-UDT ] }
        {  -153 [ SQL-GEOMETRY ] }
        {  -154 [ SQL-GEOMETRYCOLLECTION ] }
        {  -155 [ SQL-CIRCULARSTRING ] }
        {  -156 [ SQL-COMPOUNDCURVE ] }
        {  -157 [ SQL-CURVEPOLYGON ] }
        {  -158 [ SQL-FULLTEXT ] }
        {  -159 [ SQL-FULLTEXTKEY ] }
        {  -160 [ SQL-LINESTRING ] }
        {  -161 [ SQL-MULTILINESTRING ] }
        {  -162 [ SQL-MULTIPOINT ] }
        {  -163 [ SQL-MULTIPOLYGON ] }
        {  -164 [ SQL-POINT ] }
        {  -165 [ SQL-POLYGON ] }
        [ drop  SQL-TYPE-UNKNOWN ]
    } case ;


FUNCTION: SQLRETURN SQLAllocConnect ( SQLHENV environmentHandle, SQLHDBC* connectionHandlePtr )
FUNCTION: SQLRETURN SQLAllocEnv ( SQLHENV* environmentHandlePtr )
FUNCTION: SQLRETURN SQLAllocHandle ( SQLSMALLINT handleType, SQLHANDLE inputHandle, SQLHANDLE* outputHandlePtr )
FUNCTION: SQLRETURN SQLAllocStmt ( SQLHDBC connectionHandle, SQLHSTMT* statementHandlePtr )
FUNCTION: SQLRETURN SQLBindCol ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLSMALLINT targetType, SQLPOINTER targetValuePtr, SQLINTEGER bufferLength, SQLINTEGER* strlen_or_indPtr )
FUNCTION: SQLRETURN SQLBindParam ( SQLHSTMT statementHandle, SQLUSMALLINT parameterNumber, SQLSMALLINT valueType, SQLSMALLINT parameterType, SQLUINTEGER lengthPrecision, SQLSMALLINT parameterScale, SQLPOINTER parameterValuePtr, SQLINTEGER* indPtr )
FUNCTION: SQLRETURN SQLBindParameter ( SQLHSTMT statementHandle, SQLUSMALLINT parameterNumber, SQLSMALLINT inputOutputType, SQLSMALLINT valueType, SQLSMALLINT parameterType, SQLUINTEGER columnSize, SQLSMALLINT decimalDigits, SQLPOINTER parameterValuePtr, SQLINTEGER bufferLength, SQLINTEGER* indPtr )
FUNCTION: SQLRETURN SQLBrowseConnect ( SQLHDBC connectionHandle, SQLCHAR* inConnectionString, SQLSMALLINT stringLength, SQLCHAR* outConnectionString, SQLSMALLINT bufferLength, SQLSMALLINT* stringLength2Ptr )
FUNCTION: SQLRETURN SQLBulkOperations ( SQLHSTMT statementHandle, SQLSMALLINT operation )
FUNCTION: SQLRETURN SQLCancel ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLCloseCursor ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLColAttribute ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLUSMALLINT fieldIdentifier, SQLPOINTER characterAttributePtr, SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr, SQLLEN* numericAttributePtr )
FUNCTION: SQLRETURN SQLColAttributes ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLUSMALLINT fieldIdentifier, SQLPOINTER characterAttributePtr, SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr, SQLINTEGER* numericAttributePtr )
FUNCTION: SQLRETURN SQLColumnPrivileges ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3, SQLCHAR* columnName, SQLSMALLINT nameLength4 )
FUNCTION: SQLRETURN SQLColumns ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3, SQLCHAR* columnName, SQLSMALLINT nameLength4 )
FUNCTION: SQLRETURN SQLConnect ( SQLHDBC connectionHandle, SQLCHAR* serverName, SQLSMALLINT nameLength1, SQLCHAR* userName, SQLSMALLINT nameLength2, SQLCHAR* authentication, SQLSMALLINT nameLength3 )
FUNCTION: SQLRETURN SQLCopyDesc ( SQLHDESC sourceDescHandle, SQLHDESC targetDescHandle )
FUNCTION: SQLRETURN SQLDataSources ( SQLHENV environmentHandle, SQLUSMALLINT direction, SQLCHAR* serverName, SQLSMALLINT bufferLength1, SQLSMALLINT* nameLength1Ptr, SQLCHAR* description, SQLSMALLINT bufferLength2, SQLSMALLINT* nameLength2Ptr )
FUNCTION: SQLRETURN SQLDescribeCol ( SQLHSTMT statementHandle, SQLSMALLINT columnNumber, SQLCHAR* columnName, SQLSMALLINT bufferLength, SQLSMALLINT* nameLengthPtr, SQLSMALLINT* dataTypePtr, SQLUINTEGER* columnSizePtr, SQLSMALLINT* decimalDigitsPtr, SQLSMALLINT* nullablePtr )
FUNCTION: SQLRETURN SQLDescribeParam ( SQLHSTMT statementHandle, SQLUSMALLINT parameterNumber, SQLSMALLINT* dataTypePtr, SQLUINTEGER* parameterSizePtr, SQLSMALLINT* decimalDigitsPtr, SQLSMALLINT* nullablePtr )
FUNCTION: SQLRETURN SQLDisconnect ( SQLHDBC connectionHandle )
FUNCTION: SQLRETURN SQLDriverConnect ( SQLHDBC connectionHandle, SQLHWND windowHandle, SQLCHAR* inConnectionString, SQLSMALLINT stringLength, SQLCHAR* outConnectionString, SQLSMALLINT bufferLength, SQLSMALLINT* stringLength2Ptr, SQLUSMALLINT driverCompletion )
FUNCTION: SQLRETURN SQLEndTran ( SQLSMALLINT handleType, SQLHANDLE handle, SQLSMALLINT completionType )
FUNCTION: SQLRETURN SQLError ( SQLHENV environmentHandle, SQLHDBC connectionHandle, SQLHSTMT statementHandle, SQLCHAR* sqlState, SQLINTEGER* nativeErrorPtr, SQLCHAR* messageText, SQLSMALLINT bufferLength, SQLSMALLINT* textLengthPtr )
FUNCTION: SQLRETURN SQLExecute ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLExecDirect ( SQLHSTMT statementHandle, SQLCHAR* statementText, SQLINTEGER textLength )
FUNCTION: SQLRETURN SQLExtendedFetch ( SQLHSTMT statementHandle, SQLUSMALLINT fetchType, SQLLEN fetchOffset, SQLULEN* rowCountPtr, SQLUSMALLINT* rowStatusArray )
FUNCTION: SQLRETURN SQLFetch ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLFetchScroll ( SQLHSTMT statementHandle, SQLSMALLINT fetchOrientation, SQLLEN fetchOffset )
FUNCTION: SQLRETURN SQLForeignKeys ( SQLHSTMT statementHandle, SQLCHAR* pkCatalogName, SQLSMALLINT nameLength1, SQLCHAR* pkSchemaName, SQLSMALLINT nameLength2, SQLCHAR* pkTableName, SQLSMALLINT nameLength3, SQLCHAR* fkCatalogName, SQLSMALLINT nameLength4, SQLCHAR* fkSchemaName, SQLSMALLINT nameLength5, SQLCHAR* fkTableName, SQLSMALLINT nameLength6 )
FUNCTION: SQLRETURN SQLFreeConnect ( SQLHDBC connectionHandle )
FUNCTION: SQLRETURN SQLFreeHandle ( SQLSMALLINT handleType, SQLHANDLE handle )
FUNCTION: SQLRETURN SQLFreeEnv ( SQLHENV environmentHandle )
FUNCTION: SQLRETURN SQLFreeStmt ( SQLHSTMT statementHandle, SQLUSMALLINT option )
FUNCTION: SQLRETURN SQLGetConnectAttr ( SQLHDBC connectionHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER bufferLength, SQLINTEGER* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetConnectOption ( SQLHDBC connectionHandle, SQLUSMALLINT option, SQLPOINTER valuePtr )
FUNCTION: SQLRETURN SQLGetCursorName ( SQLHSTMT statementHandle, SQLCHAR* cursorName, SQLSMALLINT bufferLength, SQLSMALLINT* nameLengthPtr )
FUNCTION: SQLRETURN SQLGetData ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLSMALLINT targetType, SQLPOINTER targetValuePtr, SQLINTEGER bufferLength, SQLINTEGER* strlen_or_indPtr )
FUNCTION: SQLRETURN SQLGetDescField ( SQLHDESC descriptorHandle, SQLSMALLINT recNumber, SQLSMALLINT fieldIdentifier, SQLPOINTER valuePtr, SQLINTEGER bufferLength, SQLINTEGER* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetDescRec ( SQLHDESC descriptorHandle, SQLSMALLINT recNumber, SQLCHAR* name, SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr, SQLSMALLINT* typePtr, SQLSMALLINT* subTypePtr, SQLLEN* lengthPtr, SQLSMALLINT* precisionPtr, SQLSMALLINT* scalePtr, SQLSMALLINT* nullablePtr )
FUNCTION: SQLRETURN SQLGetDiagField ( SQLSMALLINT handleType, SQLHANDLE handle, SQLSMALLINT recNumber, SQLSMALLINT diagIdentifier, SQLPOINTER diagInfoPtr, SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetDiagRec ( SQLSMALLINT HandleType, SQLHANDLE Handle, SQLSMALLINT RecNumber, SQLCHAR* SQLState, SQLINTEGER* NativeErrorPtr, SQLCHAR* MessageText, SQLSMALLINT BufferLength, SQLSMALLINT* TextLengthPtr )
FUNCTION: SQLRETURN SQLGetEnvAttr ( SQLHENV environmentHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER bufferLength, SQLINTEGER* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetFunctions ( SQLHDBC connectionHandle, SQLUSMALLINT functionId, SQLUSMALLINT* supportedPtr )
FUNCTION: SQLRETURN SQLGetInfo ( SQLHDBC connectionHandle, SQLUSMALLINT infoType, SQLPOINTER infoValuePtr, SQLSMALLINT bufferLength, SQLSMALLINT* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetStmtAttr ( SQLHSTMT statementHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER bufferLength, SQLINTEGER* stringLengthPtr )
FUNCTION: SQLRETURN SQLGetStmtOption ( SQLHSTMT statementHandle, SQLUSMALLINT option, SQLPOINTER valuePtr )
FUNCTION: SQLRETURN SQLGetTypeInfo ( SQLHSTMT statementHandle, SQLSMALLINT dataType )
FUNCTION: SQLRETURN SQLMoreResults ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLNativeSql ( SQLHDBC connectionHandle, SQLCHAR* inStatementText, SQLINTEGER textLength1, SQLCHAR* outStatementText, SQLINTEGER bufferLength, SQLINTEGER* textLength2Ptr )
FUNCTION: SQLRETURN SQLNumParams ( SQLHSTMT statementHandle, SQLSMALLINT* parameterCountPtr )
FUNCTION: SQLRETURN SQLNumResultCols ( SQLHSTMT statementHandle, SQLSMALLINT* columnCountPtr )
FUNCTION: SQLRETURN SQLParamData ( SQLHSTMT statementHandle, SQLPOINTER* valuePtrPtr )
FUNCTION: SQLRETURN SQLParamOptions ( SQLHSTMT statementHandle, SQLULEN rowCount, SQLULEN* rowsProcessedPtr )
FUNCTION: SQLRETURN SQLPrepare ( SQLHSTMT statementHandle, SQLCHAR* statementText, SQLINTEGER length )
FUNCTION: SQLRETURN SQLPrimaryKeys ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3 )
FUNCTION: SQLRETURN SQLProcedureColumns ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* procName, SQLSMALLINT nameLength3, SQLCHAR* columnName, SQLSMALLINT nameLength4 )
FUNCTION: SQLRETURN SQLProcedures ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* procName, SQLSMALLINT nameLength3 )
FUNCTION: SQLRETURN SQLPutData ( SQLHSTMT statementHandle, SQLPOINTER dataPtr, SQLLEN stringLength )
FUNCTION: SQLRETURN SQLRowCount ( SQLHSTMT statementHandle, SQLLEN* rowCountPtr )
FUNCTION: SQLRETURN SQLSetConnectAttr ( SQLHDBC connectionHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER stringLength )
FUNCTION: SQLRETURN SQLSetConnectOption ( SQLHDBC connectionHandle, SQLUSMALLINT option, SQLULEN value )
FUNCTION: SQLRETURN SQLSetCursorName ( SQLHSTMT statementHandle, SQLCHAR* cursorName, SQLSMALLINT nameLength )
FUNCTION: SQLRETURN SQLSetDescField ( SQLHDESC descriptorHandle, SQLSMALLINT recNumber, SQLSMALLINT fieldIdentifier, SQLPOINTER valuePtr, SQLINTEGER bufferLength )
FUNCTION: SQLRETURN SQLSetDescRec ( SQLHDESC descriptorHandle, SQLSMALLINT recNumber, SQLSMALLINT type, SQLSMALLINT subType, SQLLEN length, SQLSMALLINT precision, SQLSMALLINT scale, SQLPOINTER dataPtr, SQLLEN* stringLengthPtr, SQLLEN* indicatorPtr )
FUNCTION: SQLRETURN SQLSetEnvAttr ( SQLHENV environmentHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER stringLength )
FUNCTION: SQLRETURN SQLSetParam ( SQLHSTMT statementHandle, SQLUSMALLINT parameterNumber, SQLSMALLINT valueType, SQLSMALLINT parameterType, SQLUINTEGER lengthPrecision, SQLSMALLINT parameterScale, SQLPOINTER parameterValuePtr, SQLINTEGER* indPtr )
FUNCTION: SQLRETURN SQLSetPos ( SQLHSTMT statementHandle, SQLUSMALLINT rowNumber, SQLUSMALLINT operation, SQLUSMALLINT lockType )
FUNCTION: SQLRETURN SQLSetScrollOptions ( SQLHSTMT statementHandle, SQLUSMALLINT concurrency, SQLINTEGER rowNumber, SQLUSMALLINT cacheSize )
FUNCTION: SQLRETURN SQLSetStmtAttr ( SQLHSTMT statementHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER stringLength )
FUNCTION: SQLRETURN SQLSetStmtOption ( SQLHSTMT statementHandle, SQLUSMALLINT option, SQLULEN value )
FUNCTION: SQLRETURN SQLSpecialColumns ( SQLHSTMT statementHandle, SQLUSMALLINT identifierType, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3, SQLUSMALLINT scope, SQLUSMALLINT nullable )
FUNCTION: SQLRETURN SQLStatistics ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3, SQLUSMALLINT unique, SQLUSMALLINT reserved )
FUNCTION: SQLRETURN SQLTablePrivileges ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3 )
FUNCTION: SQLRETURN SQLTables ( SQLHSTMT statementHandle, SQLCHAR* catalogName, SQLSMALLINT nameLength1, SQLCHAR* schemaName, SQLSMALLINT nameLength2, SQLCHAR* tableName, SQLSMALLINT nameLength3, SQLCHAR* tableType, SQLSMALLINT nameLength4 )

ERROR: odbc-error message ;
ERROR: odbc-invalid-handle-error message ;

: check-odbc ( retcode message -- )
    swap {
        { SQL_SUCCESS [ drop ] }
        { SQL_SUCCESS_WITH_INFO [ drop ] }
        { SQL_ERROR [ odbc-error ] }
        { SQL_INVALID_HANDLE [ odbc-invalid-handle-error ] }
        [ 2drop ]
    } case ;

: succeeded? ( n -- bool )
    ! Did the call succeed (SQL-SUCCESS or SQL-SUCCESS-WITH-INFO)
    {
        { SQL_SUCCESS [ t ] }
        { SQL_SUCCESS_WITH_INFO [ t ] }
        [ drop f ]
    } case ;

ERROR: odbc-statement-error state native-code message ;
: throw-statement-error ( hstmt -- * )
    [ SQL_HANDLE_STMT ] dip
    1
    SQL_SQLSTATE_SIZE SQLCHAR <c-array>
    0 SQLINTEGER <ref>
    SQL_MAX_MESSAGE_LENGTH SQLCHAR <c-array>
    SQL_MAX_MESSAGE_LENGTH
    0 SQLSMALLINT <ref>
    [ SQLGetDiagRec "SQLGetDiagRec" check-odbc ] 5 nkeep
    nip [ utf8 decode ] [ le> ] [ ] [ le> head utf8 decode ] quad*
    odbc-statement-error ;

: check-statement ( retcode hstmt -- )
    swap succeeded? [ drop ] [ throw-statement-error ] if ;

: alloc-handle ( type parent -- handle )
    f void* <ref> [ SQLAllocHandle ] keep swap succeeded? [
        void* deref
    ] [
        drop f
    ] if ;

: alloc-env-handle ( -- handle )
    SQL-HANDLE-ENV SQL-NULL-HANDLE alloc-handle ;

: alloc-dbc-handle ( env -- handle )
    [ SQL-HANDLE-DBC ] dip alloc-handle ;

: alloc-stmt-handle ( dbc -- handle )
    [ SQL-HANDLE-STMT ] dip alloc-handle ;

<PRIVATE

: alien-space-str ( len -- alien )
    CHAR: space <string> ascii string>alien ;

PRIVATE>

: temp-string ( length -- byte-array length )
    [ alien-space-str ] keep ;

: set-odbc-version ( env-handle -- )
    SQL-ATTR-ODBC-VERSION SQL-OV-ODBC3 0 SQLSetEnvAttr "SQLSetEnvAttr" check-odbc ;

: odbc-init ( -- env )
    alloc-env-handle [ set-odbc-version ] keep ;

: odbc-connect ( env dsn -- dbc )
    [ alloc-dbc-handle dup ] dip
    f swap utf8 string>alien dup length
    1024 temp-string 0 short <ref>
    SQL-DRIVER-NOPROMPT SQLDriverConnect "SQLDriverConnect" check-odbc ;

: odbc-disconnect ( dbc -- ) SQLDisconnect "SQLDisconnect" check-odbc ;

: odbc-prepare ( dbc string -- statement )
    [ alloc-stmt-handle dup ] dip utf8 string>alien
    dup length [ SQLPrepare ] keepdd check-statement ;

: odbc-free-statement ( statement -- )
    SQL-HANDLE-STMT swap SQLFreeHandle "SQLFreeHandle" check-odbc ;

: odbc-execute ( statement -- ) [ SQLExecute ] keep check-statement ;

: odbc-next-row ( statement -- bool ) SQLFetch succeeded? ;

: odbc-number-of-columns ( statement -- number )
    0 short <ref> [ SQLNumResultCols succeeded? ] keep swap [
        short deref
    ] [
        drop f
    ] if ;

TUPLE: column nullable digits size type name number ;

C: <column> column

:: odbc-describe-column ( statement columnNumber -- column )
    1024 :> bufferLen
    bufferLen alien-space-str :> columnName
    0 short <ref> :> nameLengthPtr
    0 short <ref> :> dataTypePtr
    0 uint  <ref> :> columnSizePtr
    0 short <ref> :> decimalDigitsPtr
    0 short <ref> :> nullablePtr
    statement columnNumber columnName bufferLen nameLengthPtr
    dataTypePtr columnSizePtr decimalDigitsPtr nullablePtr
    SQLDescribeCol "SQLDescribeCol" check-odbc
        nullablePtr short deref
        decimalDigitsPtr short deref
        columnSizePtr uint deref
        dataTypePtr short deref convert-sql-type
        columnName utf8 alien>string
        columnNumber <column> ;

: dereference-type-pointer ( byte-array column -- object )
    type>> {
        { SQL-CHAR [ utf8 alien>string ] }
        { SQL-VARCHAR [ utf8 alien>string ] }
        { SQL-LONGVARCHAR [ utf8 alien>string ] }
        { SQL-WCHAR [ utf8 alien>string ] }
        { SQL-WCHARVAR [ utf8 alien>string ] }
        { SQL-WLONGCHARVAR [ utf8 alien>string ] }
        { SQL-DECIMAL [ ascii alien>string ] }
        { SQL-TYPE-TIMESTAMP [
            "SSSSSSI" unpack-le 7 firstn
            1,000,000,000 / + instant <timestamp>
        ] }
        { SQL-SMALLINT [ short deref ] }
        { SQL-INTEGER [ long deref ] }
        { SQL-REAL [ float deref ] }
        { SQL-FLOAT [ double deref ] }
        { SQL-DOUBLE [ double deref ] }
        { SQL-TINYINT [ char deref ] }
        { SQL-BIGINT [ longlong deref ] }
        [ nip name>> "Unknown SQL Type: " prepend ]
    } case ;

TUPLE: field value column ;

C: <field> field

:: odbc-get-field ( statement column! -- field )
    column column? [
        statement column odbc-describe-column column!
    ] unless
    8192 :> bufferLen
    bufferLen alien-space-str :> targetValuePtr
    statement column number>> SQL-C-DEFAULT
    targetValuePtr bufferLen f SQLGetData
    succeeded? [
        targetValuePtr column [ dereference-type-pointer ] keep <field>
    ] [
        column [
            "SQLGetData Failed for Column: " %
            dup name>> %
            " of type: " % dup type>> name>> %
        ] "" make swap <field>
    ] if ;

: odbc-get-row-fields ( statement -- seq )
    [
        dup odbc-number-of-columns <iota> [
            1 + odbc-get-field value>> ,
        ] with each
    ] { } make ;

: (odbc-get-all-rows) ( statement -- )
    dup odbc-next-row [
        dup odbc-get-row-fields , yield (odbc-get-all-rows)
    ] [
        drop
    ] if ;

: odbc-get-all-rows ( statement -- seq )
    [ (odbc-get-all-rows) ] { } make ;

: odbc-query ( string dsn -- result )
    odbc-init swap odbc-connect [
        [
            swap odbc-prepare
            dup odbc-execute
            dup odbc-get-all-rows
            swap odbc-free-statement
        ] keep
    ] [ odbc-disconnect ] finally ;
