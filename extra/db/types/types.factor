! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations sequences.deep sequences.lib ;
IN: db.types

! ID is the Primary key
SYMBOL: +native-id+
SYMBOL: +assigned-id+

: primary-key? ( spec -- ? )
    [ { +native-id+ +assigned-id+ } member? ] contains? ;

: contains-id? ( columns id -- ? )
    swap [ member? ] with contains? ;
    
: assigned-id? ( columns -- ? ) +assigned-id+ contains-id? ;
: native-id? ( columns -- ? ) +native-id+ contains-id? ;

SYMBOL: +foreign-key+

! Same concept, SQLite has autoincrement, PostgreSQL has serial
SYMBOL: +autoincrement+
SYMBOL: +serial+
SYMBOL: +unique+

SYMBOL: +default+
SYMBOL: +null+
SYMBOL: +not-null+

SYMBOL: +has-many+

: relation? ( spec -- ? )
    [ +has-many+ = ] deep-find* nip ;

SYMBOL: INTEGER
SYMBOL: BIG_INTEGER
SYMBOL: DOUBLE

SYMBOL: BOOLEAN

SYMBOL: TEXT
SYMBOL: VARCHAR

SYMBOL: TIMESTAMP
SYMBOL: DATE

TUPLE: no-sql-type ;
: no-sql-type ( -- * ) T{ no-sql-type } throw ;

: number>string* ( n/str -- str )
    dup number? [ number>string ] when ;

: maybe-remove-id ( columns -- obj )
    [ +native-id+ swap member? not ] subset ;

: remove-relations ( columns -- newcolumns )
    [ relation? not ] subset ;

: remove-id ( columns -- obj )
    [ primary-key? not ] subset ;

! SQLite Types: http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB
! PostgreSQL Types:
! http://developer.postgresql.org/pgdocs/postgres/datatype.html

TUPLE: sql-spec slot-name column-name type modifiers ;

: spec>tuple ( spec -- tuple )
    [ ?first3 ] keep 3 ?tail* sql-spec construct-boa ;

: sql-type-hash ( -- assoc )
    H{
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "varchar" }
        { DOUBLE "real" }
        { TIMESTAMP "timestamp" }
    } ;

! HOOK: sql-type-hash db ( -- obj )
! HOOK: >sql-type-string db ( obj -- str )

: >sql-type-string ( obj -- str/f )
    dup pair? [
        first >sql-type-string
    ] [
        sql-type-hash at* [ drop "" ] unless
    ] if ;

: full-sql-type-string ( obj -- str )
    [ >sql-type-string ] keep second
    number>string " " swap 3append ;
