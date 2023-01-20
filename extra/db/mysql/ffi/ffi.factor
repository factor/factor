! Copyright (C) 2007 Berlin Brown, 2008 Doug Coleman, 2021 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
! Adapted from mysql.h and mysql.c
! Tested with MariaDB version 10.1.39
USING: alien alien.c-types alien.libraries alien.syntax
combinators system ;
IN: db.mysql.ffi

<< "mysql" {
    { [ os windows? ] [ "libmySQL.dll" stdcall ] }
    { [ os macosx? ] [ "libmysqlclient.14.dylib" cdecl ] }
    { [ os unix? ] [ "libmysqlclient.so" cdecl ] }
} cond add-library >>

LIBRARY: mysql

FUNCTION: uint mysql_errno ( void* mysql )
FUNCTION: c-string mysql_error ( void* mysql )
FUNCTION: void* mysql_init ( void* mysql )
FUNCTION: int mysql_options ( void* mysql, int option, void* arg
)
FUNCTION: void* mysql_real_connect ( void* mysql, c-string host,
c-string user, c-string password, c-string db, int port,
c-string unixsocket, long clientflag )
FUNCTION: int mysql_query ( void* mysql, c-string query )
FUNCTION: void* mysql_use_result ( void* mysql )
FUNCTION: uint mysql_field_count ( void* mysql )
FUNCTION: uint mysql_num_fields ( void* result )
FUNCTION: char** mysql_fetch_row ( void* result )
FUNCTION: ulong* mysql_fetch_lengths ( void* result )
FUNCTION: void mysql_free_result ( void* result )
FUNCTION: void mysql_close ( void* mysql )
