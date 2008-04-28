! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs db kernel math math.parser
sequences continuations sequences.deep sequences.lib
words namespaces tools.walker slots slots.private classes
mirrors classes.tuple combinators calendar.format symbols
classes.singleton accessors quotations random ;
IN: db.types

HOOK: persistent-table db ( -- hash )
HOOK: compound db ( str obj -- hash )

TUPLE: sql-spec class slot-name column-name type primary-key modifiers ;

TUPLE: literal-bind key type value ;
C: <literal-bind> literal-bind

TUPLE: generator-bind key generator-singleton type ;
C: <generator-bind> generator-bind
SINGLETON: random-id-generator

TUPLE: low-level-binding value ;
C: <low-level-binding> low-level-binding

SINGLETON: +db-assigned-id+
SINGLETON: +user-assigned-id+
SINGLETON: +random-id+
UNION: +primary-key+ +db-assigned-id+ +user-assigned-id+ +random-id+ ;

SYMBOLS: +autoincrement+ +serial+ +unique+ +default+ +null+ +not-null+
+foreign-id+ +has-many+ ;

: find-random-generator ( seq -- obj )
    [
        {
            random-generator
            system-random-generator
            secure-random-generator
        } member?
    ] find nip [ system-random-generator ] unless* ;

: primary-key? ( spec -- ? )
    primary-key>> +primary-key+? ;

: db-assigned-id-spec? ( spec -- ? )
    primary-key>> +db-assigned-id+? ;

: assigned-id-spec? ( spec -- ? )
    primary-key>> +user-assigned-id+? ;

: normalize-spec ( spec -- )
    dup type>> dup +primary-key+? [
        >>primary-key drop
    ] [
        drop dup modifiers>> [
            +primary-key+?
        ] deep-find
        [ >>primary-key drop ] [ drop ] if*
    ] if ;

: find-primary-key ( specs -- obj )
    [ primary-key>> ] find nip ;

: relation? ( spec -- ? ) [ +has-many+ = ] deep-find ;

SYMBOLS: INTEGER BIG-INTEGER SIGNED-BIG-INTEGER UNSIGNED-BIG-INTEGER
DOUBLE REAL BOOLEAN TEXT VARCHAR DATE TIME DATETIME TIMESTAMP BLOB
FACTOR-BLOB NULL ;

: spec>tuple ( class spec -- tuple )
    3 f pad-right
    [ first3 ] keep 3 tail
    sql-spec new
        swap >>modifiers
        swap >>type
        swap >>column-name
        swap >>slot-name
        swap >>class
    dup normalize-spec ;

: number>string* ( n/str -- str )
    dup number? [ number>string ] when ;

: remove-db-assigned-id ( specs -- obj )
    [ +db-assigned-id+? not ] filter ;

: remove-relations ( specs -- newcolumns )
    [ relation? not ] filter ;

: remove-id ( specs -- obj )
    [ primary-key>> not ] filter ;

! SQLite Types: http://www.sqlite.org/datatype3.html
! NULL INTEGER REAL TEXT BLOB
! PostgreSQL Types:
! http://developer.postgresql.org/pgdocs/postgres/datatype.html

ERROR: unknown-modifier ;

: lookup-modifier ( obj -- str )
    {
        { [ dup array? ] [ unclip lookup-modifier swap compound ] }
        [ persistent-table at* [ unknown-modifier ] unless third ]
    } cond ;

ERROR: no-sql-type ;

: (lookup-type) ( obj -- str )
    persistent-table at* [ no-sql-type ] unless ;

: lookup-type ( obj -- str )
    dup array? [
        unclip (lookup-type) first nip
    ] [
        (lookup-type) first
    ] if ;

: lookup-create-type ( obj -- str )
    dup array? [
        unclip (lookup-type) second swap compound
    ] [
        (lookup-type) second
    ] if ;

: single-quote ( str -- newstr )
    "'" swap "'" 3append ;

: double-quote ( str -- newstr )
    "\"" swap "\"" 3append ;

: paren ( str -- newstr )
    "(" swap ")" 3append ;

: join-space ( str1 str2 -- newstr )
    " " swap 3append ;

: modifiers ( spec -- str )
    modifiers>> [ lookup-modifier ] map " " join
    dup empty? [ " " prepend ] unless ;

HOOK: bind% db ( spec -- )
HOOK: bind# db ( spec obj -- )

: offset-of-slot ( str obj -- n )
    class "slots" word-prop slot-named slot-spec-offset ;

: get-slot-named ( name obj -- value )
    tuck offset-of-slot slot ;

: set-slot-named ( value name obj -- )
    tuck offset-of-slot set-slot ;

: tuple>filled-slots ( tuple -- alist )
    <mirror> [ nip ] assoc-filter ;

: tuple>params ( specs tuple -- obj )
    [
        >r [ type>> ] [ slot-name>> ] bi r>
        get-slot-named swap
    ] curry { } map>assoc ;
