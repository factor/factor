! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays classes.mixin classes.parser classes.singleton
combinators db2.connections kernel lexer sequences ;
IN: db2.types

HOOK: sql-type>string db-connection ( type -- string )
HOOK: sql-create-type>string db-connection ( type -- string )
HOOK: sql-modifiers>string db-connection ( modifiers -- string )
HOOK: db-type>fql-type db-connection ( name -- table-schema )

HOOK: persistent-type-hashtable db-connection ( -- hashtable )

MIXIN: sql-type
MIXIN: sql-modifier
MIXIN: sql-primary-key

INSTANCE: sql-primary-key sql-modifier

<<

: define-sql-instance ( word mixin -- )
    over define-singleton-class
    add-mixin-instance ;

: define-sql-type ( word -- )
    sql-type define-sql-instance ;

: define-sql-modifier ( word -- )
    sql-modifier define-sql-instance ;

: define-primary-key ( word -- )
    [ define-sql-type ]
    [ sql-primary-key add-mixin-instance ] bi ;

SYNTAX: SQL-TYPE:
    scan-new-class define-sql-type ;

SYNTAX: SQL-TYPES:
    ";" parse-tokens
    [ create-class-in define-sql-type ] each ;

SYNTAX: PRIMARY-KEY-TYPE:
    scan-new-class define-primary-key ;

SYNTAX: PRIMARY-KEY-TYPES:
    ";" parse-tokens
    [ create-class-in define-primary-key ] each ;

SYNTAX: SQL-MODIFIER:
    scan-new-class define-sql-modifier ;

SYNTAX: SQL-MODIFIERS:
    ";" parse-tokens
    [ create-class-in define-sql-modifier ] each ;

>>

SQL-TYPES:
    INTEGER BIG-INTEGER SIGNED-BIG-INTEGER UNSIGNED-BIG-INTEGER
    DOUBLE REAL
    BOOLEAN
    TEXT CHARACTER VARCHAR DATE
    TIME DATETIME TIMESTAMP
    BLOB FACTOR-BLOB
    URL ;

! Delete +not-null+
SQL-MODIFIERS: SERIAL AUTOINCREMENT UNIQUE DEFAULT NOT-NULL NULL
+on-update+ +on-delete+ +restrict+ +cascade+ +set-null+ +set-default+
+not-null+ +system-random-generator+ ;

PRIMARY-KEY-TYPES: +db-assigned-key+
    +user-assigned-key+
    +random-key+
    +primary-key+ ;

INSTANCE: +user-assigned-key+ sql-modifier
INSTANCE: +db-assigned-key+ sql-modifier

SYMBOL: IGNORE

ERROR: no-sql-type name ;
ERROR: no-sql-modifier name ;

: ensure-sql-type ( object -- object )
    dup sql-type? [ no-sql-type ] unless ;

: ensure-sql-modifier ( object -- object )
    dup sql-modifier? [ no-sql-modifier ] unless ;

: persistent-type>sql-type ( type -- type' )
    dup array? [ first ] when
    {
        { +db-assigned-key+ [ INTEGER ] }
        { +random-key+ [ INTEGER ] }
        [ ]
    } case ;
