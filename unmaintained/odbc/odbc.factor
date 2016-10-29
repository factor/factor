! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.strings alien.syntax combinators io.encodings.ascii kernel
locals make math sequences strings threads ;
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

: SQL-HANDLE-ENV  ( -- number ) 1 ; inline
: SQL-HANDLE-DBC  ( -- number ) 2 ; inline
: SQL-HANDLE-STMT ( -- number ) 3 ; inline
: SQL-HANDLE-DESC ( -- number ) 4 ; inline

: SQL-NULL-HANDLE ( -- alien ) f ; inline

: SQL-ATTR-ODBC-VERSION ( -- number ) 200 ; inline

: SQL-OV-ODBC2 ( -- number ) 2 <alien> ; inline
: SQL-OV-ODBC3 ( -- number ) 3 <alien> ; inline

: SQL-SUCCESS ( -- number ) 0 ; inline
: SQL-SUCCESS-WITH-INFO ( -- number ) 1 ; inline
: SQL-NO-DATA-FOUND ( -- number ) 100 ; inline

: SQL-DRIVER-NOPROMPT ( -- number ) 0 ; inline
: SQL-DRIVER-PROMPT ( -- number ) 2 ; inline

: SQL-C-DEFAULT ( -- number ) 99 ; inline

SYMBOL: SQL-CHAR
SYMBOL: SQL-VARCHAR
SYMBOL: SQL-LONGVARCHAR
SYMBOL: SQL-WCHAR
SYMBOL: SQL-WCHARVAR
SYMBOL: SQL-WLONGCHARVAR
SYMBOL: SQL-DECIMAL
SYMBOL: SQL-SMALLINT
SYMBOL: SQL-NUMERIC
SYMBOL: SQL-INTEGER
SYMBOL: SQL-REAL
SYMBOL: SQL-FLOAT
SYMBOL: SQL-DOUBLE
SYMBOL: SQL-BIT
SYMBOL: SQL-TINYINT
SYMBOL: SQL-BIGINT
SYMBOL: SQL-BINARY
SYMBOL: SQL-VARBINARY
SYMBOL: SQL-LONGVARBINARY
SYMBOL: SQL-TYPE-DATE
SYMBOL: SQL-TYPE-TIME
SYMBOL: SQL-TYPE-TIMESTAMP
SYMBOL: SQL-TYPE-UTCDATETIME
SYMBOL: SQL-TYPE-UTCTIME
SYMBOL: SQL-INTERVAL-MONTH
SYMBOL: SQL-INTERVAL-YEAR
SYMBOL: SQL-INTERVAL-YEAR-TO-MONTH
SYMBOL: SQL-INTERVAL-DAY
SYMBOL: SQL-INTERVAL-HOUR
SYMBOL: SQL-INTERVAL-MINUTE
SYMBOL: SQL-INTERVAL-SECOND
SYMBOL: SQL-INTERVAL-DAY-TO-HOUR
SYMBOL: SQL-INTERVAL-DAY-TO-MINUTE
SYMBOL: SQL-INTERVAL-DAY-TO-SECOND
SYMBOL: SQL-INTERVAL-HOUR-TO-MINUTE
SYMBOL: SQL-INTERVAL-HOUR-TO-SECOND
SYMBOL: SQL-INTERVAL-MINUTE-TO-SECOND
SYMBOL: SQL-GUID
SYMBOL: SQL-TYPE-UNKNOWN

: convert-sql-type ( number -- symbol )
    {
        { 1 [ SQL-CHAR ] }
        { 12  [ SQL-VARCHAR ] }
        { -1  [ SQL-LONGVARCHAR ] }
        { -8  [ SQL-WCHAR ] }
        { -9  [ SQL-WCHARVAR ] }
        { -10 [ SQL-WLONGCHARVAR ] }
        { 3 [ SQL-DECIMAL ] }
        { 5 [ SQL-SMALLINT ] }
        { 2 [ SQL-NUMERIC ] }
        { 4 [ SQL-INTEGER ] }
        { 7 [ SQL-REAL ] }
        { 6 [ SQL-FLOAT ] }
        { 8 [ SQL-DOUBLE ] }
        { -7 [ SQL-BIT ] }
        { -6 [ SQL-TINYINT ] }
        { -5 [ SQL-BIGINT ] }
        { -2 [ SQL-BINARY ] }
        { -3 [ SQL-VARBINARY ] }
        { -4 [ SQL-LONGVARBINARY ] }
        { 91 [ SQL-TYPE-DATE ] }
        { 92 [ SQL-TYPE-TIME ] }
        { 93 [ SQL-TYPE-TIMESTAMP ] }
        [ drop SQL-TYPE-UNKNOWN ]
    } case ;

: succeeded? ( n -- bool )
    ! Did the call succeed (SQL-SUCCESS or SQL-SUCCESS-WITH-INFO)
    {
        { SQL-SUCCESS [ t ] }
        { SQL-SUCCESS-WITH-INFO [ t ] }
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
    [ alloc-stmt-handle dup ] dip dup length SQLPrepare
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
    0 uint <ref> :> columnSizePtr
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
        dup odbc-number-of-columns [
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
        swap odbc-prepare
        dup odbc-execute
        dup odbc-get-all-rows
        swap odbc-free-statement
    ] keep odbc-disconnect ;
