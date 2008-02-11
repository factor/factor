USING: arrays assocs db kernel math math.parser
sequences continuations ;
IN: db.types


! id   serial not null primary key,
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
! SYMBOL: NULL
! SYMBOL: INTEGER
! SYMBOL: REAL
! SYMBOL: TEXT
! SYMBOL: BLOB

SYMBOL: INTEGER
SYMBOL: DOUBLE
SYMBOL: BOOLEAN

SYMBOL: TEXT
SYMBOL: VARCHAR

SYMBOL: TIMESTAMP
SYMBOL: DATE

SYMBOL: BIG_INTEGER

! SYMBOL: LOCALE
! SYMBOL: TIMEZONE
! SYMBOL: CURRENCY


! PostgreSQL Types
! http://developer.postgresql.org/pgdocs/postgres/datatype.html


: number>string* ( num/str -- str )
    dup number? [ number>string ] when ;

TUPLE: no-sql-type ;
HOOK: sql-modifiers* db ( modifiers -- str )
HOOK: >sql-type db ( obj -- str )




: maybe-remove-id ( columns -- obj )
    [ +native-id+ swap member? not ] subset ;

: remove-id ( columns -- obj )
    [ primary-key? not ] subset ;

: sql-modifiers ( spec -- seq )
    3 tail sql-modifiers* ;
