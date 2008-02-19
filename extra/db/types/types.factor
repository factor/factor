! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations sequences.deep sequences.lib
words ;
IN: db.types

TUPLE: sql-spec slot-name column-name type modifiers primary-key ;
! ID is the Primary key
! +native-id+ can be a columns type or a modifier
SYMBOL: +native-id+
! +assigned-id+ can only be a modifier
SYMBOL: +assigned-id+

: primary-key? ( obj -- ? )
    { +native-id+ +assigned-id+ } member? ;

: normalize-spec ( spec -- )
    dup sql-spec-type dup primary-key? [
        swap set-sql-spec-primary-key
    ] [
        drop dup sql-spec-modifiers [
            primary-key?
        ] deep-find
        [ swap set-sql-spec-primary-key ] [ drop ] if*
    ] if ;

: find-primary-key ( specs -- obj )
    [ sql-spec-primary-key ] find nip ;

: native-id? ( spec -- ? )
    sql-spec-primary-key +native-id+ = ;

: assigned-id? ( spec -- ? )
    sql-spec-primary-key +assigned-id+ = ;

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
    [ +has-many+ = ] deep-find ;

SYMBOL: INTEGER
SYMBOL: BIG_INTEGER
SYMBOL: DOUBLE

SYMBOL: BOOLEAN

SYMBOL: TEXT
SYMBOL: VARCHAR

SYMBOL: TIMESTAMP
SYMBOL: DATE

: spec>tuple ( spec -- tuple )
    [ ?first3 ] keep 3 ?tail*
    {
        set-sql-spec-slot-name
        set-sql-spec-column-name
        set-sql-spec-type
        set-sql-spec-modifiers
    } sql-spec construct
    dup normalize-spec ;

: sql-type-hash ( -- assoc )
    H{
        { INTEGER "integer" }
        { TEXT "text" }
        { VARCHAR "varchar" }
        { DOUBLE "real" }
        { TIMESTAMP "timestamp" }
    } ;

TUPLE: no-sql-type ;
: no-sql-type ( -- * ) T{ no-sql-type } throw ;

TUPLE: no-sql-modifier ;
: no-sql-modifier ( -- * ) T{ no-sql-modifier } throw ;

: number>string* ( n/str -- str )
    dup number? [ number>string ] when ;

: maybe-remove-id ( specs -- obj )
    [ native-id? not ] subset ;

: remove-relations ( specs -- newcolumns )
    [ relation? not ] subset ;

: remove-id ( specs -- obj )
    [ sql-spec-primary-key not ] subset ;

! SQLite Types: http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB
! PostgreSQL Types:
! http://developer.postgresql.org/pgdocs/postgres/datatype.html



HOOK: modifier-table db ( -- hash )
HOOK: compound-modifier db ( str n -- hash )

: lookup-modifier ( obj -- str )
    dup pair? [
        first2 >r lookup-modifier r> compound-modifier
    ] [
        modifier-table at*
        [ "unknown modifier" throw ] unless
    ] if ;


HOOK: type-table db ( -- hash )
HOOK: create-type-table db ( -- hash )
HOOK: compound-type db ( str n -- hash )

: lookup-type* ( obj -- str )
    dup pair? [
        first lookup-type*
    ] [
        type-table at*
        [ no-sql-type ] unless
    ] if ;

: lookup-create-type ( obj -- str )
    dup pair? [
        first2 >r lookup-create-type r> compound-type
    ] [
        dup create-type-table at*
        [ nip ] [ drop lookup-type* ] if
    ] if ;

: lookup-type ( obj create? -- str )
    [ lookup-create-type ] [ lookup-type* ] if ;
