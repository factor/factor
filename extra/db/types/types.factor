! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations ;
IN: db.types

! ID is the Primary key
SYMBOL: +native-id+
SYMBOL: +assigned-id+

: primary-key? ( spec -- ? )
    [ { +native-id+ +assigned-id+ } member? ] contains? ;

! Same concept, SQLite has autoincrement, PostgreSQL has serial
SYMBOL: +autoincrement+
SYMBOL: +serial+
SYMBOL: +unique+

SYMBOL: +default+
SYMBOL: +null+
SYMBOL: +not-null+

SYMBOL: +has-many+

! SQLite Types
! http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB

SYMBOL: INTEGER
SYMBOL: DOUBLE
SYMBOL: BOOLEAN

SYMBOL: TEXT
SYMBOL: VARCHAR

SYMBOL: TIMESTAMP
SYMBOL: DATE

SYMBOL: BIG_INTEGER

! PostgreSQL Types
! http://developer.postgresql.org/pgdocs/postgres/datatype.html


: number>string* ( num/str -- str )
    dup number? [ number>string ] when ;

TUPLE: no-sql-type ;
HOOK: sql-modifiers* db ( modifiers -- str )
HOOK: >sql-type db ( obj -- str )

! HOOK: >factor-type db ( obj -- obj )

: maybe-remove-id ( columns -- obj )
    [ +native-id+ swap member? not ] subset ;

: remove-id ( columns -- obj )
    [ primary-key? not ] subset ;

: sql-modifiers ( spec -- seq )
    3 tail sql-modifiers* ;
