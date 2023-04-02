! File: cnc
! Version: 0.1
! DRI: Dave Carlton
! Description: CNC Machine
! Copyright (C) 2022 Dave Carlton.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.enums alien.syntax classes.tuple db db.sqlite
 db.tuples db.types kernel math namespaces sequences
proquint uuid variables  ;
IN: cnc

! Utility
: quintid ( -- id )   uuid1 string>uuid  32 >quint ; 

: (inch>mm) ( bit inch -- bit mm )
    over units>> 1 = [ 25.4 / ] when ;

: clean-whitespace ( str -- 'str )
    [  CHAR: \x09 dupd =
       over  CHAR: \x0a = or
       [ drop CHAR: \x20 ] when
    ] map string-squeeze-spaces ;

SYMBOL: sql-statement 
SYMBOL: cnc-db-path cnc-db-path [ "/Users/davec/Dropbox/3CL/Data/cnc.db" ]  initialize
DEFER: bit
DEFER: convert-bit-slots
TUPLE: cnc-db < sqlite-db ;
: <cnc-db> ( -- <cnc-db> )
    cnc-db new
    cnc-db-path get >>path ;

: with-cncdb ( quot -- )
    '[ <cnc-db> _ with-db ] call ; inline

: cnc-db>bit ( cnc-dbvt -- bit )
    bit slots>tuple convert-bit-slots ;

: do-cncdb ( statement -- result ? )
    sql-statement set
    [ sql-statement get sql-query ] with-cncdb
    dup empty?
    [ f ] [ [ cnc-db>bit ] map t ] if ;


ENUM: units +mm+ +in+ ;



