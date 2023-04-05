! Copyright (C) 2012 PolyMicro Systems.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors alien.c-types alien.data arrays calendar.format
combinators db db.errors db.types io.backend io.encodings.string
io.encodings.utf8 kernel math mysql mysql.ffi namespaces present
sequences serialize urls ;

IN: mysql.lib

ERROR: mysql-error < db-error n string ;
ERROR: mysql-sql-error < sql-error n string ;

: throw-mysql-error ( n -- * )
    dup mysql-error-messages nth mysql-error ;

: mysql-statement-error ( -- * )
    MYSQL_ERROR
    db-connection get handle>> mysql_error mysql-sql-error ;

: mysql-check-result ( n -- )
    {
        { MYSQL_OK [ ] }
        { MYSQL_ERROR [ mysql-statement-error ] }
        [ throw-mysql-error ]
    } case ;

: mysql-open ( path -- db x )
    normalize-path
    { void* } [ mysql_init mysql-check-result ]
    with-out-parameters ;

: mysql-close ( db x -- )
    mysql_close mysql-check-result ;

! : mysql-prepare ( db sql -- handle )
!     utf8 encode dup length
!     { void* void* }
!     [ mysql_stmt_prepare mysql-check-result ]
!     with-out-parameters drop ;

: mysql-bind-parameter-index ( handle name -- index )
    mysql_stmt_bind_param ;

: parameter-index ( handle name text -- handle name text )
    [ dupd mysql-bind-parameter-index ] dip ;

! : mysql-bind-text ( handle index text -- )
!     utf8 encode dup length MYSQL_TRANSIENT
!     mysql_bind_text mysql-check-result ;

! : mysql-bind-int ( handle i n -- )
!     mysql_bind_int mysql-check-result ;

! : mysql-bind-int64 ( handle i n -- )
!     mysql_bind_int64 mysql-check-result ;

! : mysql-bind-uint64 ( handle i n -- )
!     mysql_bind_uint64 mysql-check-result ;

! : mysql-bind-double ( handle i x -- )
!     mysql_bind_double mysql-check-result ;

! : mysql-bind-null ( handle i -- )
!     mysql_bind_null mysql-check-result ;

! : mysql-bind-blob ( handle i byte-array -- )
!     dup length MYSQL_TRANSIENT
!     mysql_bind_blob mysql-check-result ;

! : mysql-bind-text-by-name ( handle name text -- )
!     parameter-index mysql-bind-text ;

: mysql-bind-int-by-name ( handle name int -- )
    parameter-index mysql-bind-int;

! : mysql-bind-int64-by-name ( handle name int64 -- )
!     parameter-index mysql-bind-int64 ;

! ! : mysql-bind-uint64-by-name ( handle name int64 -- )
! !     parameter-index mysql-bind-uint64 ;

! : mysql-bind-boolean-by-name ( handle name obj -- )
!     >boolean 1 0 ? parameter-index mysql-bind-int ;

! : mysql-bind-double-by-name ( handle name double -- )
!     parameter-index mysql-bind-double ;

! : mysql-bind-blob-by-name ( handle name blob -- )
!     parameter-index mysql-bind-blob ;

! : mysql-bind-null-by-name ( handle name obj -- )
!     parameter-index drop mysql-bind-null ;

: (mysql-bind-type) ( handle key value type -- )
    dup array? [ first ] when
    {
        { INTEGER [ mysql-bind-int-by-name ] }
        { BIG-INTEGER [ mysql-bind-int64-by-name ] }
        { SIGNED-BIG-INTEGER [ mysql-bind-int64-by-name ] }
        ! { UNSIGNED-BIG-INTEGER [ mysql-bind-uint64-by-name ] }
        { BOOLEAN [ mysql-bind-boolean-by-name ] }
        { TEXT [ mysql-bind-text-by-name ] }
        { VARCHAR [ mysql-bind-text-by-name ] }
        { DOUBLE [ mysql-bind-double-by-name ] }
        { DATE [ timestamp>ymd mysql-bind-text-by-name ] }
        { TIME [ timestamp>hms mysql-bind-text-by-name ] }
        { DATETIME [ timestamp>ymdhms mysql-bind-text-by-name ] }
        { TIMESTAMP [ timestamp>ymdhms mysql-bind-text-by-name ] }
        { BLOB [ mysql-bind-blob-by-name ] }
        { FACTOR-BLOB [ object>bytes mysql-bind-blob-by-name ] }
        { URL [ present mysql-bind-text-by-name ] }
        { +db-assigned-id+ [ mysql-bind-int-by-name ] }
        { +random-id+ [ mysql-bind-int64-by-name ] }
        { NULL [ mysql-bind-null-by-name ] }
        [ no-sql-type ]
    } case;

: mysql-bind-type ( handle key value type -- )
    #! null and empty values need to be set by mysql-bind-null-by-name
    over [
        NULL = [ 2drop NULL NULL ] when
    ] [
        drop NULL 
    ] if* (mysql-bind-type);

! : mysql-finalize ( handle -- ) mysql_finalize mysql-check-result ;
! : mysql-reset ( handle -- ) mysql_reset mysql-check-result ;
! : mysql-clear-bindings ( handle -- )
!     mysql_clear_bindings mysql-check-result ;
! : mysql-#columns ( query -- int ) mysql_column_count ;
! : mysql-column ( handle index -- string ) mysql_column_text ;
! : mysql-column-name ( handle index -- string ) mysql_column_name ;
! : mysql-column-type ( handle index -- string ) mysql_column_type ;

! : mysql-column-blob ( handle index -- byte-array/f )
!     [ mysql_column_bytes ] 2keep
!     pick zero? [
!         3drop f
!     ] [
!         mysql_column_blob swap memory>byte-array
!     ] if ;

! : mysql-column-typed ( handle index type -- obj )
!     dup array? [ first ] when
!     {
!         { +db-assigned-id+ [ mysql_column_int64  ] }
!         { +random-id+ [ mysql-column-uint64 ] }
!         { INTEGER [ mysql_column_int ] }
!         { BIG-INTEGER [ mysql_column_int64 ] }
!         { SIGNED-BIG-INTEGER [ mysql_column_int64 ] }
!         { UNSIGNED-BIG-INTEGER [ mysql-column-uint64 ] }
!         { BOOLEAN [ mysql_column_int 1 = ] }
!         { DOUBLE [ mysql_column_double ] }
!         { TEXT [ mysql_column_text ] }
!         { VARCHAR [ mysql_column_text ] }
!         { DATE [ mysql_column_text dup [ ymd>timestamp ] when ] }
!         { TIME [ mysql_column_text dup [ hms>timestamp ] when ] }
!         { TIMESTAMP [ mysql_column_text dup [ ymdhms>timestamp ] when ] }
!         { DATETIME [ mysql_column_text dup [ ymdhms>timestamp ] when ] }
!         { BLOB [ mysql-column-blob ] }
!         { URL [ mysql_column_text dup [ >url ] when ] }
!         { FACTOR-BLOB [ mysql-column-blob dup [ bytes>object ] when ] }
!         [ no-sql-type ]
!     } case ;

: mysql-row ( handle -- seq )
    dup mysql-#columns [ mysql-column ] with { } map-integers ;

: mysql-step-has-more-rows? ( prepared -- ? )
    {
        { MYSQL_ROW [ t ] }
        { MYSQL_DONE [ f ] }
        [ mysql-check-result f ]
    } case ;

: mysql-next ( prepared -- ? )
    mysql_next_result mysql-step-has-more-rows? ;

