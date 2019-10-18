! Copyright (C) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel alien alien.syntax combinators alien.c-types
       strings sequences namespaces words math threads ;
IN: odbc

"odbc" "odbc32.dll" "stdcall" add-library

LIBRARY: odbc

TYPEDEF: void* usb_dev_handle*
TYPEDEF: short SQLRETURN
TYPEDEF: short SQLSMALLINT
TYPEDEF: short* SQLSMALLINT*
TYPEDEF: ushort SQLUSMALLINT
TYPEDEF: uint* SQLUINTEGER*
TYPEDEF: int SQLINTEGER
TYPEDEF: char SQLCHAR
TYPEDEF: char* SQLCHAR*
TYPEDEF: void* SQLHANDLE
TYPEDEF: void* SQLHANDLE*
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
    { [ dup 1 = ] [ drop SQL-CHAR ] }
    { [ dup 12 = ] [ drop SQL-VARCHAR ] }
    { [ dup -1 = ] [ drop SQL-LONGVARCHAR ] }
    { [ dup -8 = ] [ drop SQL-WCHAR ] }
    { [ dup -9 = ] [ drop SQL-WCHARVAR ] }
    { [ dup -10 = ] [ drop SQL-WLONGCHARVAR ] }
    { [ dup 3 = ] [ drop SQL-DECIMAL ] }
    { [ dup 5 = ] [ drop SQL-SMALLINT ] }
    { [ dup 2 = ] [ drop SQL-NUMERIC ] }
    { [ dup 4 = ] [ drop SQL-INTEGER ] }
    { [ dup 7 = ] [ drop SQL-REAL ] }
    { [ dup 6 = ] [ drop SQL-FLOAT ] }
    { [ dup 8 = ] [ drop SQL-DOUBLE ] }
    { [ dup -7 = ] [ drop SQL-BIT ] }
    { [ dup -6 = ] [ drop SQL-TINYINT ] }
    { [ dup -5 = ] [ drop SQL-BIGINT ] }
    { [ dup -2 = ] [ drop SQL-BINARY ] }
    { [ dup -3 = ] [ drop SQL-VARBINARY ] }   
    { [ dup -4 = ] [ drop SQL-LONGVARBINARY ] }
    { [ dup 91 = ] [ drop SQL-TYPE-DATE ] }
    { [ dup 92 = ] [ drop SQL-TYPE-TIME ] }
    { [ dup 93 = ] [ drop SQL-TYPE-TIMESTAMP ] }
    { [ t ] [ drop SQL-TYPE-UNKNOWN ] }
  } cond ;

: succeeded? ( n -- bool )
  #! Did the call succeed (SQL-SUCCESS or SQL-SUCCESS-WITH-INFO)
  {
    { [ dup SQL-SUCCESS = ] [ drop t ] }
    { [ dup SQL-SUCCESS-WITH-INFO = ] [ drop t ] }
    { [ t ] [ drop f ] }
  } cond ;  

FUNCTION: SQLRETURN SQLAllocHandle ( SQLSMALLINT handleType, SQLHANDLE inputHandle, SQLHANDLE* outputHandlePtr ) ;
FUNCTION: SQLRETURN SQLSetEnvAttr ( SQLHENV environmentHandle, SQLINTEGER attribute, SQLPOINTER valuePtr, SQLINTEGER stringLength ) ;
FUNCTION: SQLRETURN SQLDriverConnect ( SQLHDBC connectionHandle, SQLHWND windowHandle, SQLCHAR* inConnectionString, SQLSMALLINT stringLength, SQLCHAR* outConnectionString, SQLSMALLINT bufferLength, SQLSMALLINT* stringLength2Ptr, SQLUSMALLINT driverCompletion ) ; 
FUNCTION: SQLRETURN SQLDisconnect ( SQLHDBC connectionHandle ) ;
FUNCTION: SQLRETURN SQLPrepare ( SQLHSTMT statementHandle, SQLCHAR* statementText, SQLINTEGER length ) ;
FUNCTION: SQLRETURN SQLExecute ( SQLHSTMT statementHandle ) ;
FUNCTION: SQLRETURN SQLFreeHandle ( SQLSMALLINT handleType, SQLHANDLE handle ) ;
FUNCTION: SQLRETURN SQLFetch ( SQLHSTMT statementHandle ) ;
FUNCTION: SQLRETURN SQLNumResultCols ( SQLHSTMT statementHandle, SQLSMALLINT* columnCountPtr ) ;
FUNCTION: SQLRETURN SQLDescribeCol ( SQLHSTMT statementHandle, SQLSMALLINT columnNumber, SQLCHAR* columnName, SQLSMALLINT bufferLength, SQLSMALLINT* nameLengthPtr, SQLSMALLINT* dataTypePtr, SQLUINTEGER* columnSizePtr, SQLSMALLINT* decimalDigitsPtr, SQLSMALLINT* nullablePtr ) ;
FUNCTION: SQLRETURN SQLGetData ( SQLHSTMT statementHandle, SQLUSMALLINT columnNumber, SQLSMALLINT targetType, SQLPOINTER targetValuePtr, SQLINTEGER bufferLength, SQLINTEGER* strlen_or_indPtr ) ;

: alloc-handle ( type parent -- handle )
  f <void*> [ SQLAllocHandle ] keep swap succeeded? [
    *void*
  ] [
    drop f
  ] if ;

: alloc-env-handle ( -- handle )
  SQL-HANDLE-ENV SQL-NULL-HANDLE alloc-handle ;

: alloc-dbc-handle ( env -- handle )
  SQL-HANDLE-DBC swap alloc-handle ;

: alloc-stmt-handle ( dbc -- handle )
  SQL-HANDLE-STMT swap alloc-handle ;

: temp-string ( length -- byte-array length )
  [ CHAR: \space  <string> string>char-alien ] keep ;

: odbc-init ( -- env )
  alloc-env-handle
  [ 
    SQL-ATTR-ODBC-VERSION SQL-OV-ODBC3 0 SQLSetEnvAttr 
    succeeded? [ "odbc-init failed" throw ] unless
  ] keep ;

: odbc-connect ( env dsn -- dbc )
   >r alloc-dbc-handle dup r> 
   f swap dup length 1024 temp-string 0 <short> SQL-DRIVER-NOPROMPT 
   SQLDriverConnect succeeded? [ "odbc-connect failed" throw ] unless ;

: odbc-disconnect ( dbc -- )
  SQLDisconnect succeeded? [ "odbc-disconnect failed" throw ] unless ;     

: odbc-prepare ( dbc string -- statement )
  >r alloc-stmt-handle dup r> dup length SQLPrepare succeeded? [ "odbc-prepare failed" throw ] unless ;

: odbc-free-statement ( statement -- )
  SQL-HANDLE-STMT swap SQLFreeHandle succeeded? [ "odbc-free-statement failed" throw ] unless ;

: odbc-execute ( statement --  )
  SQLExecute succeeded? [ "odbc-execute failed" throw ] unless ;

: odbc-next-row ( statement -- bool )
  SQLFetch succeeded? ;

: odbc-number-of-columns ( statement -- number )
  0 <short> [ SQLNumResultCols succeeded? ] keep swap [
    *short
  ] [
    drop f
  ] if ;

TUPLE: column nullable digits size type name number ;

C: <column> column

: odbc-describe-column ( statement n -- column )
  dup >r
  1024 CHAR: \space <string> string>char-alien dup >r
  1024 
  0 <short>
  0 <short> dup >r
  0 <uint> dup >r
  0 <short> dup >r
  0 <short> dup >r
  SQLDescribeCol succeeded? [
    r> *short 
    r> *short 
    r> *uint 
    r> *short convert-sql-type 
    r> alien>char-string 
    r> <column> 
  ] [
    r> drop r> drop r> drop r> drop r> drop r> drop
    "odbc-describe-column failed" throw
  ] if ;

: dereference-type-pointer ( byte-array column -- object )
  column-type {
    { [ dup SQL-CHAR = ] [ drop alien>char-string ] }
    { [ dup SQL-VARCHAR = ] [ drop alien>char-string ] }
    { [ dup SQL-LONGVARCHAR = ] [ drop alien>char-string ] }
    { [ dup SQL-WCHAR = ] [ drop alien>char-string ] }
    { [ dup SQL-WCHARVAR = ] [ drop alien>char-string ] }
    { [ dup SQL-WLONGCHARVAR = ] [ drop alien>char-string ] }
    { [ dup SQL-SMALLINT = ] [ drop *short ] }
    { [ dup SQL-INTEGER = ] [ drop *long ] }
    { [ dup SQL-REAL = ] [ drop *float ] }
    { [ dup SQL-FLOAT = ] [ drop *double ] }
    { [ dup SQL-DOUBLE = ] [ drop *double ] }
    { [ dup SQL-TINYINT = ] [ drop *char  ] }
    { [ dup SQL-BIGINT = ] [ drop *longlong ] }
    { [ t ] [ nip [ "Unknown SQL Type: " % word-name % ] "" make ] }    
  } cond ;

TUPLE: field value column ;

C: <field> field

: odbc-get-field ( statement column -- field )
  dup column? [ dupd odbc-describe-column ] unless dup >r column-number
  SQL-C-DEFAULT
  8192 CHAR: \space <string> string>char-alien dup >r
  8192 
  f SQLGetData succeeded? [
    r> r> [ dereference-type-pointer ] keep <field>
  ] [
    r> drop r> [ 
      "SQLGetData Failed for Column: " % 
      dup column-name % 
      " of type: " % dup column-type word-name %
    ] "" make swap <field>
  ] if ;

: odbc-get-row-fields ( statement -- seq )
  [
    dup odbc-number-of-columns [
      1+ odbc-get-field field-value ,
    ] curry* each 
  ] { } make ;

: (odbc-get-all-rows) ( statement -- )
  dup odbc-next-row [ dup odbc-get-row-fields , yield (odbc-get-all-rows) ] [ drop ] if ; 
    
: odbc-get-all-rows ( statement -- seq )
  [ (odbc-get-all-rows) ] { } make ;
  
: odbc-query ( string dsn -- result )
  odbc-init swap odbc-connect [
    swap odbc-prepare
    dup odbc-execute
    dup odbc-get-all-rows
    swap odbc-free-statement
  ] keep odbc-disconnect ;