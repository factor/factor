! Copyright (C) 2008 Chris Double, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.strings arrays
calendar.format calendar.parser combinators db db.errors
db.sqlite.errors db.sqlite.ffi db.types io.backend
io.encodings.string io.encodings.utf8 kernel math namespaces
present sequences serialize urls ;
IN: db.sqlite.lib

: sqlite3-compile-options ( -- seq )
    0 [
        [ 1 + ] [ sqlite3_compileoption_get ] bi dup
    ] [ ] produce 2nip ;

ERROR: sqlite3-error < db-error n string ;

: sqlite3-other-error ( n -- * )
    dup sqlite3-error-messages nth sqlite3-error ;

: sqlite3-statement-error ( -- * )
    db-connection get handle>> sqlite3_errmsg alien>native-string
    parse-sqlite3-sql-error throw ;

: sqlite3-check-result ( n -- )
    {
        { SQLITE_OK [ ] }
        { SQLITE_ERROR [ sqlite3-statement-error ] }
        [ sqlite3-other-error ]
    } case ;

: sqlite3-open ( path -- db )
    normalize-path native-string>alien
    { void* } [ sqlite3_open sqlite3-check-result ]
    with-out-parameters ;

: sqlite3-close ( db -- )
    sqlite3_close sqlite3-check-result ;

: sqlite3-prepare ( db sql -- handle )
    [ native-string>alien ] [ length ] bi
    { void* void* }
    [ sqlite3_prepare_v2 sqlite3-check-result ]
    with-out-parameters drop ;

: sqlite3-bind-parameter-index ( handle name -- index )
    native-string>alien
    sqlite3_bind_parameter_index ;

: parameter-index ( handle name text -- handle name text )
    [ dupd sqlite3-bind-parameter-index ] dip ;

: sqlite3-bind-text ( handle index text -- )
    utf8 encode dup length SQLITE_TRANSIENT
    sqlite3_bind_text sqlite3-check-result ;

: sqlite3-bind-int ( handle i n -- )
    sqlite3_bind_int sqlite3-check-result ;

: sqlite3-bind-int64 ( handle i n -- )
    sqlite3_bind_int64 sqlite3-check-result ;

: sqlite3-bind-uint64 ( handle i n -- )
    ! there is no sqlite3_bind_uint64 function
    sqlite3_bind_int64 sqlite3-check-result ;

: sqlite3-bind-double ( handle i x -- )
    sqlite3_bind_double sqlite3-check-result ;

: sqlite3-bind-null ( handle i -- )
    sqlite3_bind_null sqlite3-check-result ;

: sqlite3-bind-blob ( handle i byte-array -- )
    dup length SQLITE_TRANSIENT
    sqlite3_bind_blob sqlite3-check-result ;

: sqlite3-bind-text-by-name ( handle name text -- )
    parameter-index sqlite3-bind-text ;

: sqlite3-bind-int-by-name ( handle name int -- )
    parameter-index sqlite3-bind-int ;

: sqlite3-bind-int64-by-name ( handle name int64 -- )
    parameter-index sqlite3-bind-int64 ;

: sqlite3-bind-uint64-by-name ( handle name int64 -- )
    parameter-index sqlite3-bind-uint64 ;

: sqlite3-bind-boolean-by-name ( handle name obj -- )
    >boolean 1 0 ? parameter-index sqlite3-bind-int ;

: sqlite3-bind-double-by-name ( handle name double -- )
    parameter-index sqlite3-bind-double ;

: sqlite3-bind-blob-by-name ( handle name blob -- )
    parameter-index sqlite3-bind-blob ;

: sqlite3-bind-null-by-name ( handle name obj -- )
    parameter-index drop sqlite3-bind-null ;

: (sqlite3-bind-type) ( handle key value type -- )
    dup array? [ first ] when
    {
        { INTEGER [ sqlite3-bind-int-by-name ] }
        { BIG-INTEGER [ sqlite3-bind-int64-by-name ] }
        { SIGNED-BIG-INTEGER [ sqlite3-bind-int64-by-name ] }
        { UNSIGNED-BIG-INTEGER [ sqlite3-bind-uint64-by-name ] }
        { BOOLEAN [ sqlite3-bind-boolean-by-name ] }
        { TEXT [ sqlite3-bind-text-by-name ] }
        { VARCHAR [ sqlite3-bind-text-by-name ] }
        { DOUBLE [ sqlite3-bind-double-by-name ] }
        { DATE [ timestamp>ymd sqlite3-bind-text-by-name ] }
        { TIME [ duration>hms sqlite3-bind-text-by-name ] }
        { DATETIME [ timestamp>ymdhms sqlite3-bind-text-by-name ] }
        { TIMESTAMP [ timestamp>ymdhms sqlite3-bind-text-by-name ] }
        { BLOB [ sqlite3-bind-blob-by-name ] }
        { FACTOR-BLOB [ object>bytes sqlite3-bind-blob-by-name ] }
        { URL [ present sqlite3-bind-text-by-name ] }
        { +db-assigned-id+ [ sqlite3-bind-int-by-name ] }
        { +random-id+ [ sqlite3-bind-int64-by-name ] }
        { NULL [ sqlite3-bind-null-by-name ] }
        [ no-sql-type ]
    } case ;

: sqlite3-bind-type ( handle key value type -- )
    ! null and empty values need to be set by sqlite3-bind-null-by-name
    over [
        NULL = [ 2drop NULL NULL ] when
    ] [
        drop NULL
    ] if* (sqlite3-bind-type) ;

: sqlite3-finalize ( handle -- ) sqlite3_finalize sqlite3-check-result ;
: sqlite3-reset ( handle -- ) sqlite3_reset sqlite3-check-result ;
: sqlite3-clear-bindings ( handle -- )
    sqlite3_clear_bindings sqlite3-check-result ;
: sqlite3-#columns ( query -- int ) sqlite3_column_count ;
: sqlite3-column ( handle index -- string ) sqlite3_column_text alien>native-string ;
: sqlite3-column-name ( handle index -- string ) sqlite3_column_name alien>native-string ;
: sqlite3-column-type ( handle index -- string ) sqlite3_column_type alien>native-string ;


: sqlite3-column-null ( sqlite n obj -- obj/f )
    [ sqlite3_column_type SQLITE_NULL = f ] dip ? ; inline

! sqlite_column_int returns 0 for both a ``0`` and for ``NULL``
! so call sqlite3_column_type if it's 0
: sqlite3-column-int ( handle index -- int/f )
    2dup sqlite3_column_int dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-int64 ( handle index -- int/f )
    2dup sqlite3_column_int64 dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-uint64 ( handle index -- int/f )
    ! there is no sqlite3_column_uint64
    2dup sqlite3_column_int64 dup 0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-double ( handle index -- int/f )
    2dup sqlite3_column_double dup 0.0 = [ sqlite3-column-null ] [ 2nip ] if ;

: sqlite3-column-blob ( handle index -- byte-array/f )
    [ sqlite3_column_bytes ] 2keep
    pick zero? [
        3drop f
    ] [
        sqlite3_column_blob swap memory>byte-array
    ] if ;

: sqlite3-column-typed ( handle index type -- obj )
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
        { TEXT [ sqlite3_column_text alien>native-string ] }
        { VARCHAR [ sqlite3_column_text alien>native-string ] }
        { DATE [ sqlite3_column_text [ alien>native-string ymd>timestamp ] ?call ] }
        { TIME [ sqlite3_column_text [ alien>native-string hms>duration ] ?call ] }
        { TIMESTAMP [ sqlite3_column_text [ alien>native-string ymdhms>timestamp ] ?call ] }
        { DATETIME [ sqlite3_column_text [ alien>native-string ymdhms>timestamp ] ?call ] }
        { URL [ sqlite3_column_text [ alien>native-string >url ] ?call ] }
        { FACTOR-BLOB [ sqlite3-column-blob [ alien>native-string bytes>object ] ?call ] }
        { BLOB [ sqlite3-column-blob ] }
        [ no-sql-type ]
    } case ;

: sqlite3-row ( handle -- seq )
    dup sqlite3-#columns [ sqlite3-column ] with map-integers ;

: sqlite3-step-has-more-rows? ( prepared -- ? )
    {
        { SQLITE_ROW [ t ] }
        { SQLITE_DONE [ f ] }
        [ sqlite3-check-result f ]
    } case ;

: sqlite3-next ( prepared -- ? )
    sqlite3_step sqlite3-step-has-more-rows? ;

: sqlite3-libversion ( -- string )
    sqlite3_libversion alien>native-string ;

: current-sqlite3-filename ( -- path/f )
    db-connection get [
        handle>> native-string>alien f sqlite3_db_filename
        alien>native-string
    ] [ f ] if* ;