! Copyright (C) 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types assocs kernel math math.parser sequences
db.sqlite.ffi ;
IN: db.sqlite.lib

TUPLE: sqlite-error n message ;

: sqlite-check-result ( result -- )
    dup SQLITE_OK = [
        drop
    ] [
        dup sqlite-error-messages nth
        sqlite-error construct-boa throw
    ] if ;

: sqlite-open ( filename -- db )
    "void*" <c-object>
    [ sqlite3_open sqlite-check-result ] keep *void* ;

: sqlite-close ( db -- )
    sqlite3_close sqlite-check-result ;

: sqlite-prepare ( db sql -- statement )
    #! TODO: Support multiple statements in the SQL string.
    dup length "void*" <c-object> "void*" <c-object>
    [ sqlite3_prepare sqlite-check-result ] 2keep
    drop *void* ;

: sqlite-bind-text ( statement index text -- )
    dup number? [ number>string ] when
    dup length SQLITE_TRANSIENT sqlite3_bind_text sqlite-check-result ;

: sqlite-bind-parameter-index ( statement name -- index )
    sqlite3_bind_parameter_index ;

: sqlite-bind-text-by-name ( statement name text -- )
    >r dupd sqlite-bind-parameter-index r> sqlite-bind-text ;

: sqlite-bind-assoc ( statement assoc -- )
    swap [
        -rot sqlite-bind-text-by-name
    ] curry assoc-each ;

: sqlite-finalize ( statement -- )
    sqlite3_finalize sqlite-check-result ;

: sqlite-reset ( statement -- )
    sqlite3_reset sqlite-check-result ;

: sqlite-#columns ( query -- int )
    sqlite3_column_count ;

: sqlite-column ( statement index -- string )
    sqlite3_column_text ;

: sqlite-row ( statement -- seq )
    dup sqlite-#columns [ sqlite-column ] with map ;

! 2dup sqlite3_column_type .
! SQLITE_INTEGER     1
! SQLITE_FLOAT       2
! SQLITE_TEXT        3
! SQLITE_BLOB        4
! SQLITE_NULL        5

: step-complete? ( step-result -- bool )
    dup SQLITE_ROW =  [
        drop f
    ] [
        dup SQLITE_DONE = [ drop t ] [ sqlite-check-result t ] if
    ] if ;

: sqlite-step ( prepared -- )
    dup sqlite3_step step-complete? [
        drop
    ] [
        sqlite-step
    ] if ;

: sqlite-next ( prepared -- ? )
    sqlite3_step step-complete? ;
