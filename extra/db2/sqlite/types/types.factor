! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays calendar.format combinators db2.types
db2.sqlite.ffi db2.sqlite.lib math fry
kernel present sequences serialize urls ;
IN: db2.sqlite.types

: (bind-sqlite-type) ( handle key value type -- )
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
        { TIME [ timestamp>hms sqlite-bind-text-by-name ] }
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

: bind-next-sqlite-type ( handle key value type -- )
    dup array? [ first ] when
    {
        { INTEGER [ sqlite-bind-int ] }
        { BIG-INTEGER [ sqlite-bind-int64 ] }
        { SIGNED-BIG-INTEGER [ sqlite-bind-int64 ] }
        { UNSIGNED-BIG-INTEGER [ sqlite-bind-uint64 ] }
        { BOOLEAN [ sqlite-bind-boolean ] }
        { TEXT [ sqlite-bind-text ] }
        { VARCHAR [ sqlite-bind-text ] }
        { DOUBLE [ sqlite-bind-double ] }
        { DATE [ timestamp>ymd sqlite-bind-text ] }
        { TIME [ timestamp>hms sqlite-bind-text ] }
        { DATETIME [ timestamp>ymdhms sqlite-bind-text ] }
        { TIMESTAMP [ timestamp>ymdhms sqlite-bind-text ] }
        { BLOB [ sqlite-bind-blob ] }
        { FACTOR-BLOB [ object>bytes sqlite-bind-blob ] }
        { URL [ present sqlite-bind-text ] }
        { +db-assigned-id+ [ sqlite-bind-int ] }
        { +random-id+ [ sqlite-bind-int64 ] }
        { NULL [ drop sqlite-bind-null ] }
        [ no-sql-type ]
    } case ;

: bind-sqlite-type ( handle key value type -- )
    #! null and empty values need to be set by sqlite-bind-null-by-name
    over [
        NULL = [ 2drop NULL NULL ] when
    ] [
        drop NULL
    ] if* (bind-sqlite-type) ;

: sqlite-type ( handle index type -- obj )
    dup array? [ first ] when
    {
        { +db-assigned-id+ [ sqlite3_column_int64  ] }
        { +random-id+ [ sqlite3-column-uint64 ] }
        { INTEGER [ sqlite3_column_int ] }
        { BIG-INTEGER [ sqlite3_column_int64 ] }
        { SIGNED-BIG-INTEGER [ sqlite3_column_int64 ] }
        { UNSIGNED-BIG-INTEGER [ sqlite3-column-uint64 ] }
        { BOOLEAN [ sqlite3_column_int 1 = ] }
        { DOUBLE [ sqlite3_column_double ] }
        { TEXT [ sqlite3_column_text ] }
        { VARCHAR [ sqlite3_column_text ] }
        { DATE [ sqlite3_column_text [ ymd>timestamp ] ?when ] }
        { TIME [ sqlite3_column_text [ hms>timestamp ] ?when ] }
        { TIMESTAMP [ sqlite3_column_text [ ymdhms>timestamp ] ?when ] }
        { DATETIME [ sqlite3_column_text [ ymdhms>timestamp ] ?when ] }
        { BLOB [ sqlite-column-blob ] }
        { URL [ sqlite3_column_text [ >url ] ?when ] }
        { FACTOR-BLOB [ sqlite-column-blob [ bytes>object ] ?when ] }
        [ no-sql-type ]
    } case ;

M: sqlite-statement bind-sequence ( sequence statement -- )
    handle>> '[
        [ _ ] 2dip 1+ swap sqlite-bind-text
    ] each-index ;

M: sqlite-statement bind-typed-sequence ( sequence statement -- )
    handle>> '[
        [ _ ] 2dip 1+ swap first2 swap bind-next-sqlite-type
    ] each-index ;
