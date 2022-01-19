! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.strings arrays
calendar.format combinators postgresql.db2.connections
postgresql.db2.connections.private
postgresql.db2.ffi postgresql.db2.lib db2.types destructors
io.encodings.utf8 kernel math math.parser multiline sequences
serialize strings urls ;
IN: postgresql.db2.types

M: postgresql-db-connection sql-type>string
    dup array? [ first ] when
    {
        { INTEGER [ "INTEGER" ] }
        { BIG-INTEGER [ "INTEGER " ] }
        { SIGNED-BIG-INTEGER [ "BIGINT" ] }
        { UNSIGNED-BIG-INTEGER [ "BIGINT" ] }
        { DOUBLE [ "DOUBLE" ] }
        { REAL [ "DOUBLE" ] }
        { BOOLEAN [ "BOOLEAN" ] }
        { TEXT [ "TEXT" ] }
        { VARCHAR [ "TEXT" ] }
        { CHARACTER [ "TEXT" ] }
        { DATE [ "DATE" ] }
        { TIME [ "TIME" ] }
        { DATETIME [ "TIMESTAMP" ] }
        { TIMESTAMP [ "TIMESTAMP" ] }
        { BLOB [ "BYTEA" ] }
        { FACTOR-BLOB [ "BYTEA" ] }
        { URL [ "TEXT" ] }
        { +db-assigned-key+ [ "INTEGER" ] }
        { +random-key+ [ "BIGINT" ] }
        [ no-sql-type ]
    } case ;

M: postgresql-db-connection sql-create-type>string
    dup array? [ first ] when
    {
        { INTEGER [ "INTEGER" ] }
        { BIG-INTEGER [ "INTEGER " ] }
        { SIGNED-BIG-INTEGER [ "BIGINT" ] }
        { UNSIGNED-BIG-INTEGER [ "BIGINT" ] }
        { DOUBLE [ "DOUBLE" ] }
        { REAL [ "DOUBLE" ] }
        { BOOLEAN [ "BOOLEAN" ] }
        { TEXT [ "TEXT" ] }
        { VARCHAR [ "TEXT" ] }
        { CHARACTER [ "TEXT" ] }
        { DATE [ "DATE" ] }
        { TIME [ "TIME" ] }
        { DATETIME [ "TIMESTAMP" ] }
        { TIMESTAMP [ "TIMESTAMP" ] }
        { BLOB [ "BYTEA" ] }
        { FACTOR-BLOB [ "BYTEA" ] }
        { URL [ "TEXT" ] }
        { +db-assigned-key+ [ "SERIAL" ] }
        { +random-key+ [ "BIGINT" ] }
        [ no-sql-type ]
    } case ;

/*
: postgresql-column-typed ( handle row column type -- obj )
    dup array? [ first ] when
    {
        { +db-assigned-key+ [ pq-get-number ] }
        { +random-key+ [ pq-get-number ] }
        { INTEGER [ pq-get-number ] }
        { BIG-INTEGER [ pq-get-number ] }
        { DOUBLE [ pq-get-number ] }
        { TEXT [ pq-get-string ] }
        { VARCHAR [ pq-get-string ] }
        { CHARACTER [ pq-get-string ] }
        { DATE [ pq-get-string dup [ ymd>timestamp ] when ] }
        { TIME [ pq-get-string dup [ hms>duration ] when ] }
        { TIMESTAMP [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { DATETIME [ pq-get-string dup [ ymdhms>timestamp ] when ] }
        { BLOB [ pq-get-blob ] }
        { URL [ pq-get-string dup [ >url ] when ] }
        { FACTOR-BLOB [
            pq-get-blob
            dup [ bytes>object ] when ] }
        [ no-sql-type ]
    } case ;
*/

: postgresql-modifier>string ( symbol -- string )
    {
        { NULL [ "NULL" ] }
        { NOT-NULL [ "NOT NULL" ] }
        { SERIAL [ "SERIAL" ] }
        { AUTOINCREMENT [ "AUTOINCREMENT" ] }
        { +primary-key+ [ "" ] }
        [ no-sql-modifier ]
    } case ;

M: postgresql-db-connection sql-modifiers>string
    [ postgresql-modifier>string ] map " " join ;
