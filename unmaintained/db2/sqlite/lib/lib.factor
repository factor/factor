! Copyright (C) 2008 Chris Double, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays calendar.format
combinators db2.sqlite.errors
io.backend io.encodings.string io.encodings.utf8 kernel math
namespaces present sequences serialize urls db2.sqlite.ffi ;
IN: db2.sqlite.lib

: sqlite-check-result ( n -- )
    {
        { SQLITE_OK [ ] }
        { SQLITE_ERROR [ sqlite-statement-error ] }
        [ throw-sqlite-error ]
    } case ;

: sqlite-open ( path -- db )
    "void*" <c-object>
    [ sqlite3_open sqlite-check-result ] keep *void* ;

: sqlite-close ( db -- )
    sqlite3_close sqlite-check-result ;

: sqlite-prepare ( db sql -- handle )
    utf8 encode dup length "void*" <c-object> "void*" <c-object>
    [ sqlite3_prepare_v2 sqlite-check-result ] 2keep
    drop *void* ;

: sqlite-bind-parameter-index ( handle name -- index )
    sqlite3_bind_parameter_index ;

: parameter-index ( handle name text -- handle name text )
    [ dupd sqlite-bind-parameter-index ] dip ;

: sqlite-bind-text ( handle index text -- )
    utf8 encode dup length SQLITE_TRANSIENT
    sqlite3_bind_text sqlite-check-result ;

: sqlite-bind-int ( handle i n -- )
    sqlite3_bind_int sqlite-check-result ;

: sqlite-bind-int64 ( handle i n -- )
    sqlite3_bind_int64 sqlite-check-result ;

: sqlite-bind-uint64 ( handle i n -- )
    sqlite3-bind-uint64 sqlite-check-result ;

: sqlite-bind-boolean ( handle name obj -- )
    >boolean 1 0 ? sqlite-bind-int ;

: sqlite-bind-double ( handle i x -- )
    sqlite3_bind_double sqlite-check-result ;

: sqlite-bind-null ( handle i -- )
    sqlite3_bind_null sqlite-check-result ;

: sqlite-bind-blob ( handle i byte-array -- )
    dup length SQLITE_TRANSIENT
    sqlite3_bind_blob sqlite-check-result ;

: sqlite-bind-text-by-name ( handle name text -- )
    parameter-index sqlite-bind-text ;

: sqlite-bind-int-by-name ( handle name int -- )
    parameter-index sqlite-bind-int ;

: sqlite-bind-int64-by-name ( handle name int64 -- )
    parameter-index sqlite-bind-int64 ;

: sqlite-bind-uint64-by-name ( handle name int64 -- )
    parameter-index sqlite-bind-uint64 ;

: sqlite-bind-boolean-by-name ( handle name obj -- )
    >boolean 1 0 ? parameter-index sqlite-bind-int ;

: sqlite-bind-double-by-name ( handle name double -- )
    parameter-index sqlite-bind-double ;

: sqlite-bind-blob-by-name ( handle name blob -- )
    parameter-index sqlite-bind-blob ;

: sqlite-bind-null-by-name ( handle name obj -- )
    parameter-index drop sqlite-bind-null ;

: sqlite-finalize ( handle -- ) sqlite3_finalize sqlite-check-result ;
: sqlite-reset ( handle -- ) sqlite3_reset sqlite-check-result ;
: sqlite-clear-bindings ( handle -- )
    sqlite3_clear_bindings sqlite-check-result ;
: sqlite-#columns ( query -- int ) sqlite3_column_count ;
: sqlite-column ( handle index -- string ) sqlite3_column_text ;
: sqlite-column-name ( handle index -- string ) sqlite3_column_name ;
: sqlite-column-type ( handle index -- string ) sqlite3_column_type ;

: sqlite-column-blob ( handle index -- byte-array/f )
    [ sqlite3_column_bytes ] 2keep
    pick zero? [
        3drop f
    ] [
        sqlite3_column_blob swap memory>byte-array
    ] if ;

: sqlite-step-has-more-rows? ( prepared -- ? )
    {
        { SQLITE_ROW [ t ] }
        { SQLITE_DONE [ f ] }
        [ sqlite-check-result f ]
    } case ;

: sqlite-next ( prepared -- ? )
    sqlite3_step sqlite-step-has-more-rows? ;

