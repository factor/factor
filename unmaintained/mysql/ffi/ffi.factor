! Copyright (C) 2007 Berlin Brown, 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
! Adapted from mysql.h and mysql.c
! Tested with MySQL version - 5.0.24a
USING: alien alien.c-types alien.libraries alien.syntax combinators
system ;
IN: db.mysql.ffi

<< "mysql" {
    { [ os windows? ] [ "libmySQL.dll" stdcall ] }
    { [ os macosx? ] [ "libmysqlclient.14.dylib" cdecl ] }
    { [ os unix? ] [ "libmysqlclient.so.14" cdecl ] }
} cond add-library >>

LIBRARY: mysql

FUNCTION: void* mysql_init ( void* mysql ) ;
FUNCTION: char* mysql_error ( void* mysql ) ;
FUNCTION: void* mysql_real_connect ( void* mysql, char* host, char* user, char* passwd, char* db, int port, char* unixsocket, long clientflag ) ;
FUNCTION: void mysql_close ( void* sock ) ;
FUNCTION: int mysql_query ( void* mysql, char* q ) ;
FUNCTION: void* mysql_use_result ( void* mysql ) ;
FUNCTION: void mysql_free_result ( void* result ) ;
FUNCTION: char** mysql_fetch_row ( void* result ) ;
FUNCTION: int mysql_num_fields ( void* result ) ;
FUNCTION: ulong mysql_affected_rows ( void* mysql ) ;
