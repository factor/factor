! Copyright (C) 2008 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data arrays calendar.format
calendar.parser combinators db db.errors db.sqlite.errors
db.sqlite.ffi db.types io.backend io.encodings.string
io.encodings.utf8 kernel math namespaces present sequences
serialize urls ;
IN: db.sqlite.lib

: sqlite-compile-options ( -- seq )
    0 [
        [ 1 + ] [ sqlite3_compileoption_get ] bi dup
    ] [ ] produce 2nip ;

ERROR: sqlite-error < db-error n string ;

: sqlite-other-error ( n -- * )
    dup sqlite-error-messages nth sqlite-error ;

: sqlite-statement-error ( -- * )
    db-connection get handle>> sqlite3_errmsg
    parse-sqlite-sql-error throw ;

: sqlite-check-result ( n -- )
    {
        { SQLITE_OK [ ] }
        { SQLITE_ERROR [ sqlite-statement-error ] }
        [ sqlite-other-error ]
    } case ;

: sqlite-open ( path -- db )
    normalize-path
    { void* } [ sqlite3_open sqlite-check-result ]
    with-out-parameters ;

: sqlite-close ( db -- )
    sqlite3_close sqlite-check-result ;

: sqlite-prepare ( db sql -- handle )
    utf8 encode dup length
    { void* void* }
    [ sqlite3_prepare_v2 sqlite-check-result ]
    with-out-parameters drop ;

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

: (sqlite-bind-type) ( handle key value type -- )
    dup array? [ first ] when
    {
        { INTEGER [ sqlite-bind-int-by-name ] }
        { BIG-INTEGER [ sqlite-bind-int64-by-name ] }
        { SIGNED-BIG-INTEGER [ sqlite-bind-int64-by-name ] }
        { UNSIGNED-BIG-INTEGER [ sqlite-bind-uint64-by-name ] }
        { BOOLEAN [ sqlite-bind-boolean-by-name ] }
        { TEXT [ sqlite-bind-text-by-name ] }
        { VARCHAR [ sqlite-bind-text-by-name ] }
        { DOUBLE [ sqlite-bind-double-by-name ] }
        { DATE [ timestamp>ymd sqlite-bind-text-by-name ] }
        { TIME [ duration>hms sqlite-bind-text-by-name ] }
        { DATETIME [ timestamp>ymdhms sqlite-bind-text-by-name ] }
        { TIMESTAMP [ timestamp>ymdhms sqlite-bind-text-by-name ] }
        { BLOB [ sqlite-bind-blob-by-name ] }
        { FACTOR-BLOB [ object>bytes sqlite-bind-blob-by-name ] }
        { URL [ present sqlite-bind-text-by-name ] }
        { +db-assigned-id+ [ sqlite-bind-int-by-name ] }
        { +random-id+ [ sqlite-bind-int64-by-name ] }
        { NULL [ sqlite-bind-null-by-name ] }
        [ no-sql-type ]
    } case ;

: sqlite-bind-type ( handle key value type -- )
    ! null and empty values need to be set by sqlite-bind-null-by-name
    over [
        NULL = [ 2drop NULL NULL ] when
    ] [
        drop NULL
    ] if* (sqlite-bind-type) ;

: sqlite-finalize ( handle -- ) sqlite3_finalize sqlite-check-result ;
: sqlite-reset ( handle -- ) sqlite3_reset sqlite-check-result ;
: sqlite-clear-bindings ( handle -- )
    sqlite3_clear_bindings sqlite-check-result ;
: sqlite-#columns ( query -- int ) sqlite3_column_count ;
: sqlite-column ( handle index -- string ) sqlite3_column_text ;
: sqlite-column-name ( handle index -- string ) sqlite3_column_name ;
: sqlite-column-type ( handle index -- string ) sqlite3_column_type ;


: sqlite3-column-null ( sqlite n obj -- obj/f )
    [ sqlite3_column_type SQLITE_NULL = f ] dip ? ; inline

! sqlite_column_int returns 0 for both a ``0`` and for ``NULL``
! so call sqlite3_column_type if it's 0
: sqlite3-column-int ( handle index -- int/f )
    2dup sqlite3_column_int dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-int64 ( handle index -- int/f )
    2dup sqlite3_column_int64 dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-uint64 ( handle index -- int/f )
    2dup sqlite3_column_uint64 dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-double ( handle index -- int/f )
    2dup sqlite3_column_double dup 0.0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite-column-blob ( handle index -- byte-array/f )
    [ sqlite3_column_bytes ] 2keep
    pick zero? [
        3drop f
    ] [
        sqlite3_column_blob swap memory>byte-array
    ] if ;

: sqlite-column-typed ( handle index type -- obj )
    dup array? [ first ] when
    {
        { +db-assigned-id+ [ sqlite3_column_int64  ] }
        { +random-id+ [ sqlite3-column-uint64 ] }
        { INTEGER [ sqlite3-column-int ] }
        { BIG-INTEGER [ sqlite3-column-int64 ] }
        { SIGNED-BIG-INTEGER [ sqlite3-column-int64 ] }
        { UNSIGNED-BIG-INTEGER [ sqlite3-column-uint64 ] }
        { BOOLEAN [ sqlite3-column-int 1 = ] }
        { DOUBLE [ sqlite3-column-double ] }
        { TEXT [ sqlite3_column_text ] }
        { VARCHAR [ sqlite3_column_text ] }
        { DATE [ sqlite3_column_text dup [ ymd>timestamp ] when ] }
        { TIME [ sqlite3_column_text dup [ hms>duration ] when ] }
        { TIMESTAMP [ sqlite3_column_text dup [ ymdhms>timestamp ] when ] }
        { DATETIME [ sqlite3_column_text dup [ ymdhms>timestamp ] when ] }
        { BLOB [ sqlite-column-blob ] }
        { URL [ sqlite3_column_text dup [ >url ] when ] }
        { FACTOR-BLOB [ sqlite-column-blob dup [ bytes>object ] when ] }
        [ no-sql-type ]
    } case ;

: sqlite-row ( handle -- seq )
    dup sqlite-#columns [ sqlite-column ] with map-integers ;

: sqlite-step-has-more-rows? ( prepared -- ? )
    {
        { SQLITE_ROW [ t ] }
        { SQLITE_DONE [ f ] }
        [ sqlite-check-result f ]
    } case ;

: sqlite-next ( prepared -- ? )
    sqlite3_step sqlite-step-has-more-rows? ;
