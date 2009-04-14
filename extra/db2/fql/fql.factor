! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators constructors db2
db2.private db2.sqlite.lib db2.statements db2.utils destructors
kernel make math.parser sequences strings assocs ;
IN: db2.fql

TUPLE: fql-statement sql in out ;

GENERIC: expand-fql* ( object -- sequence/fql-statement )
GENERIC: normalize-fql ( object -- sequence/fql-statement )

! M: object normalize-fql ;

: ?1array ( obj -- array )
    dup string? [ 1array ] when ; inline

TUPLE: insert into names values ;
CONSTRUCTOR: insert ( into names values -- obj ) ;
M: insert normalize-fql ( insert -- insert )
    [ [ ?1array ] ?when ] change-names ;

TUPLE: update tables keys values where order-by limit ;
CONSTRUCTOR: update ( tables keys values where -- obj ) ;
M: update normalize-fql ( insert -- insert )
    [ [ ?1array ] ?when ] change-tables
    [ [ ?1array ] ?when ] change-keys
    [ [ ?1array ] ?when ] change-values
    [ [ ?1array ] ?when ] change-order-by ;

TUPLE: delete tables where order-by limit ;
CONSTRUCTOR: delete ( tables keys values where -- obj ) ;
M: delete normalize-fql ( insert -- insert )
    [ [ ?1array ] ?when ] change-tables
    [ [ ?1array ] ?when ] change-order-by ;

TUPLE: select names from where group-by order-by offset limit ;
CONSTRUCTOR: select ( names from -- obj ) ;
M: select normalize-fql ( select -- select )
    [ [ ?1array ] ?when ] change-names
    [ [ ?1array ] ?when ] change-from
    [ [ ?1array ] ?when ] change-group-by
    [ [ ?1array ] ?when ] change-order-by ;

TUPLE: where ;

: expand-fql ( object1 -- object2 ) normalize-fql expand-fql* ;

M: insert expand-fql*
    [ fql-statement new ] dip
    [
        {
            [ "insert into " % into>> % ]
            [ " (" % names>> ", " join % ")" % ]
            [ " values (" % values>> length "?" <array> ", " join % ");" % ]
            [ values>> >>in ]
        } cleave
    ] "" make >>sql ;

M: update expand-fql*
    [ fql-statement new ] dip
    [
        {
            [ "update " % tables>> ", " join % ]
            [
                " set " % [ keys>> ] [ values>> ] bi 
                zip [ ", " % ] [ first2 [ % ] dip " = " % % ] interleave
            ]
            ! [ "  " % from>> ", " join % ]
            [ where>> [ " where " % [ expand-fql % ] when* ] when* ]
            [ order-by>> [ " order by " % ", " join % ] when* ]
            [ limit>> [ " limit " % # ] when* ]
        } cleave
    ] "" make >>sql ;

M: delete expand-fql*
    [ fql-statement new ] dip
    [
        {
            [ "delete from " % tables>> ", " join % ]
            [ where>> [ " where " % [ expand-fql % ] when* ] when* ]
                [ order-by>> [ " order by " % ", " join % ] when* ]
            [ limit>> [ " limit " % # ] when* ]
        } cleave
    ] "" make >>sql ;

M: select expand-fql*
    [ fql-statement new ] dip
    [
        {
            [ "select " % names>> ", " join % ]
            [ " from " % from>> ", " join % ]
            [ where>> [ " where " % [ expand-fql % ] when* ] when* ]
            [ group-by>> [ " group by " % ", " join % ] when* ]
            [ order-by>> [ " order by " % ", " join % ] when* ]
            [ offset>> [ " offset " % # ] when* ]
            [ limit>> [ " limit " % # ] when* ]
        } cleave
    ] "" make >>sql ;

M: fql-statement sql-command ( sql -- )
    sql>> sql-command ;

M: fql-statement sql-query ( sql -- sequence )
    sql>> sql-query ;

M: fql-statement sql-bind-command ( fql-statement -- )
    [ in>> ] [ sql>> ] bi sql-bind-command* ;

M: fql-statement sql-bind-query ( fql-statement -- out-sequence )
    [ in>> ] [ sql>> ] bi sql-bind-query* ;

M: fql-statement sql-bind-typed-command ( string -- )
    [ in>> ] [ sql>> ] bi sql-bind-typed-command* ;

M: fql-statement sql-bind-typed-query ( string -- out-sequence )
    [ in>> ] [ sql>> ] bi sql-bind-typed-query* ;
