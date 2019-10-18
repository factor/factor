! Copyright (C) 2007 Chris Double, 2016 Alexander Ilin.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.strings alien.syntax combinators continuations
io.encodings.ascii kernel locals make math sequences strings
threads ;
FROM: alien.c-types => float short ;
IN: odbc

<< "odbc" "odbc32.dll" stdcall add-library >>

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

CONSTANT: SQL-HANDLE-ENV  1
CONSTANT: SQL-HANDLE-DBC  2
CONSTANT: SQL-HANDLE-STMT 3
CONSTANT: SQL-HANDLE-DESC 4

CONSTANT: SQL-NULL-HANDLE f

CONSTANT: SQL-ATTR-ODBC-VERSION 200

: SQL-OV-ODBC2 ( -- number ) 2 <alien> ; inline
: SQL-OV-ODBC3 ( -- number ) 3 <alien> ; inline

CONSTANT: SQL_ERROR 0
CONSTANT: SQL_SUCCESS 0
CONSTANT: SQL_SUCCESS_WITH_INFO 1
CONSTANT: SQL_INVALID_HANDLE -2
CONSTANT: SQL_NO_DATA 100

CONSTANT: SQL_NO_DATA_FOUND 100

CONSTANT: SQL-DRIVER-NOPROMPT 0
CONSTANT: SQL-DRIVER-PROMPT 2

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
    SQL-GUID
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
        [ drop  SQL-TYPE-UNKNOWN ]
    } case ;

: succeeded? ( n -- bool )
    ! Did the call succeed (SQL-SUCCESS or SQL-SUCCESS-WITH-INFO)
    {
        { SQL_SUCCESS [ t ] }
        { SQL_SUCCESS_WITH_INFO [ t ] }
        [ drop f ]
    } case ;

FUNCTION: SQLRETURN SQLAllocHandle ( SQLSMALLINT handleType, SQLHANDLE inputHandle, SQLHANDLE* outputHandlePtr )
FUNCTION: SQLRETURN SQLSetEnvAttr ( SQLHENV environmentHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER stringLength )
FUNCTION: SQLRETURN SQLDriverConnect ( SQLHDBC connectionHandle, SQLHWND windowHandle, SQLCHAR* inConnectionString, SQLSMALLINT stringLength, SQLCHAR* outConnectionString, SQLSMALLINT bufferLength, SQLSMALLINT* stringLength2Ptr, SQLUSMALLINT driverCompletion )
FUNCTION: SQLRETURN SQLDisconnect ( SQLHDBC connectionHandle )
FUNCTION: SQLRETURN SQLPrepare ( SQLHSTMT statementHandle, SQLCHAR* statementText, SQLINTEGER length )
FUNCTION: SQLRETURN SQLExecute ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLFreeHandle ( SQLSMALLINT handleType, SQLHANDLE handle )
FUNCTION: SQLRETURN SQLFetch ( SQLHSTMT statementHandle )
FUNCTION: SQLRETURN SQLNumResultCols ( SQLHSTMT statementHandle, SQLSMALLINT* columnCountPtr )
FUNCTION: SQLRETURN SQLDescribeCol ( SQLHSTMT statementHandle, SQLSMALLINT columnNumber, SQLCHAR* columnName, SQLSMALLINT bufferLength, SQLSMALLINT* nameLengthPtr, SQLSMALLINT* dataTypePtr, SQLUINTEGER* columnSizePtr, SQLSMALLINT* decimalDigitsPtr, SQLSMALLINT* nullablePtr )
FUNCTION: SQLRETURN SQLGetData ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLSMALLINT targetType, SQLPOINTER targetValuePtr, SQLINTEGER bufferLength, SQLINTEGER* strlen_or_indPtr )
FUNCTION: SQLRETURN SQLGetDiagRec (
     SQLSMALLINT     HandleType,
     SQLHANDLE       Handle,
     SQLSMALLINT     RecNumber,
     SQLCHAR*       SQLState,
     SQLINTEGER*    NativeErrorPtr,
     SQLCHAR*       MessageText,
     SQLSMALLINT     BufferLength,
     SQLSMALLINT*   TextLengthPtr )

: alloc-handle ( type parent -- handle )
    f void* <ref> [ SQLAllocHandle ] keep swap succeeded? [
        void* deref
    ] [
        drop f
    ] if ;

: alloc-env-handle ( -- handle )
    SQL-HANDLE-ENV SQL-NULL-HANDLE alloc-handle ;

: alloc-dbc-handle ( env -- handle )
    SQL-HANDLE-DBC swap alloc-handle ;

: alloc-stmt-handle ( dbc -- handle )
    SQL-HANDLE-STMT swap alloc-handle ;

<PRIVATE

: alien-space-str ( len -- alien )
    CHAR: space <string> ascii string>alien ;

PRIVATE>

: temp-string ( length -- byte-array length )
    [ alien-space-str ] keep ;

: odbc-init ( -- env )
    alloc-env-handle
    [
        SQL-ATTR-ODBC-VERSION SQL-OV-ODBC3 0 SQLSetEnvAttr
        succeeded? [ "odbc-init failed" throw ] unless
    ] keep ;

: odbc-connect ( env dsn -- dbc )
    [ alloc-dbc-handle dup ] dip
    f swap ascii string>alien dup length
    1024 temp-string 0 short <ref>
    SQL-DRIVER-NOPROMPT SQLDriverConnect
    succeeded? [ "odbc-connect failed" throw ] unless ;

: odbc-disconnect ( dbc -- )
    SQLDisconnect succeeded? [ "odbc-disconnect failed" throw ] unless ;

: odbc-prepare ( dbc string -- statement )
    [ alloc-stmt-handle dup ] dip ascii string>alien
    dup length SQLPrepare
    succeeded? [ "odbc-prepare failed" throw ] unless ;

: odbc-free-statement ( statement -- )
    SQL-HANDLE-STMT swap SQLFreeHandle
    succeeded? [ "odbc-free-statement failed" throw ] unless ;

: odbc-execute ( statement --  )
    SQLExecute succeeded? [ "odbc-execute failed" throw ] unless ;

: odbc-next-row ( statement -- bool )
    SQLFetch succeeded? ;

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
    SQLDescribeCol succeeded? [
        nullablePtr short deref
        decimalDigitsPtr short deref
        columnSizePtr uint deref
        dataTypePtr short deref convert-sql-type
        columnName ascii alien>string
        columnNumber <column>
    ] [
        "odbc-describe-column failed" throw
    ] if ;

: dereference-type-pointer ( byte-array column -- object )
    type>> {
        { SQL-CHAR [ ascii alien>string ] }
        { SQL-VARCHAR [ ascii alien>string ] }
        { SQL-LONGVARCHAR [ ascii alien>string ] }
        { SQL-WCHAR [ ascii alien>string ] }
        { SQL-WCHARVAR [ ascii alien>string ] }
        { SQL-WLONGCHARVAR [ ascii alien>string ] }
        { SQL-SMALLINT [ short deref ] }
        { SQL-INTEGER [ long deref ] }
        { SQL-REAL [ float deref ] }
        { SQL-FLOAT [ double deref ] }
        { SQL-DOUBLE [ double deref ] }
        { SQL-TINYINT [ char deref ] }
        { SQL-BIGINT [ longlong deref ] }
        [ nip [ "Unknown SQL Type: " % name>> % ] "" make ]
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
    ] [ odbc-disconnect ] [ ] cleanup ;
