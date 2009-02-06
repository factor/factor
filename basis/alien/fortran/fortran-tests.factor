! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.fortran alien.structs
alien.syntax arrays assocs kernel namespaces sequences tools.test ;
IN: alien.fortran.tests

F-RECORD: fortran_test_record
    { "integer"     "foo" }
    { "real"        "bar" }
    { "character*4" "bas" } ;

! fortran-name>symbol-name

[ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
[ "fun_times__" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
[ "funtimes___" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

! fortran-type>c-type

[ "short" ]
[ "integer*2" fortran-type>c-type ] unit-test

[ "int" ]
[ "integer*4" fortran-type>c-type ] unit-test

[ "int" ]
[ "INTEGER" fortran-type>c-type ] unit-test

[ "longlong" ]
[ "iNteger*8" fortran-type>c-type ] unit-test

[ "int[0]" ]
[ "integer(*)" fortran-type>c-type ] unit-test

[ "int[0]" ]
[ "integer(3,*)" fortran-type>c-type ] unit-test

[ "int[3]" ]
[ "integer(3)" fortran-type>c-type ] unit-test

[ "int[6]" ]
[ "integer(3,2)" fortran-type>c-type ] unit-test

[ "int[24]" ]
[ "integer(4,3,2)" fortran-type>c-type ] unit-test

[ "char[1]" ]
[ "character" fortran-type>c-type ] unit-test

[ "char[17]" ]
[ "character*17" fortran-type>c-type ] unit-test

[ "char[17]" ]
[ "character(17)" fortran-type>c-type ] unit-test

[ "int" ]
[ "logical" fortran-type>c-type ] unit-test

[ "float" ]
[ "real" fortran-type>c-type ] unit-test

[ "double" ]
[ "double-precision" fortran-type>c-type ] unit-test

[ "float" ]
[ "real*4" fortran-type>c-type ] unit-test

[ "double" ]
[ "real*8" fortran-type>c-type ] unit-test

[ "(fortran-complex)" ]
[ "complex" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "double-complex" fortran-type>c-type ] unit-test

[ "(fortran-complex)" ]
[ "complex*8" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "complex*16" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "complex*16" fortran-type>c-type ] unit-test

[ "fortran_test_record" ]
[ "fortran_test_record" fortran-type>c-type ] unit-test

! fortran-arg-type>c-type

[ "int*" { } ]
[ "integer" fortran-arg-type>c-type ] unit-test

[ "int*" { } ]
[ "integer(3)" fortran-arg-type>c-type ] unit-test

[ "int*" { } ]
[ "integer(*)" fortran-arg-type>c-type ] unit-test

[ "fortran_test_record*" { } ]
[ "fortran_test_record" fortran-arg-type>c-type ] unit-test

[ "char*" { "long" } ]
[ "character" fortran-arg-type>c-type ] unit-test

[ "char*" { "long" } ]
[ "character(17)" fortran-arg-type>c-type ] unit-test

! fortran-ret-type>c-type

[ "void" { "char*" "long" } ]
[ "character(17)" fortran-ret-type>c-type ] unit-test

[ "int" { } ]
[ "integer" fortran-ret-type>c-type ] unit-test

[ "int" { } ]
[ "logical" fortran-ret-type>c-type ] unit-test

[ "double" { } ]
[ "real" fortran-ret-type>c-type ] unit-test

[ "double" { } ]
[ "double-precision" fortran-ret-type>c-type ] unit-test

[ "void" { "(fortran-complex)*" } ]
[ "complex" fortran-ret-type>c-type ] unit-test

[ "void" { "(fortran-double-complex)*" } ]
[ "double-complex" fortran-ret-type>c-type ] unit-test

[ "void" { "int*" } ]
[ "integer(*)" fortran-ret-type>c-type ] unit-test

[ "void" { "fortran_test_record*" } ]
[ "fortran_test_record" fortran-ret-type>c-type ] unit-test

! fortran-sig>c-sig

[ "double" { "int*" "char*" "float*" "double*" "long" } ]
[ "real" { "integer" "character*17" "real" "real*8" } fortran-sig>c-sig ]
unit-test

[ "void" { "char*" "long" "char*" "char*" "int*" "long" "long" } ]
[ "character*18" { "character*17" "character" "integer" } fortran-sig>c-sig ]
unit-test

[ "void" { "(fortran-complex)*" "char*" "char*" "int*" "long" "long" } ]
[ "complex" { "character*17" "character" "integer" } fortran-sig>c-sig ]
unit-test

! fortran-record>c-struct

[ {
    { "double"   "ex"  }
    { "float"    "wye" }
    { "int"      "zee" }
    { "char[20]" "woo" }
} ] [
    {
        { "DOUBLE-PRECISION" "EX"  }
        { "REAL"             "WYE" }
        { "INTEGER"          "ZEE" }
        { "CHARACTER(20)"    "WOO" }
    } fortran-record>c-struct
] unit-test

! F-RECORD:

[ 12 ] [ "fortran_test_record" heap-size ] unit-test
[  0 ] [ "foo" "fortran_test_record" offset-of ] unit-test
[  4 ] [ "bar" "fortran_test_record" offset-of ] unit-test
[  8 ] [ "bas" "fortran_test_record" offset-of ] unit-test

! fortran-arg>c-args

[ B{ 128 } { } ]
[ 128 "integer*1" fortran-arg>c-args ] unit-test

little-endian? [ B{ 128 0 } { } ] [ B{ 0 128 } { } ] ?
[ 128 "integer*2" fortran-arg>c-args ] unit-test

little-endian? [ B{ 128 0 0 0 } { } ] [ B{ 0 0 0 128 } { } ] ?
[ 128 "integer*4" fortran-arg>c-args ] unit-test

little-endian? [ B{ 128 0 0 0 0 0 0 0 } { } ] [ B{ 0 0 0 0 0 0 0 128 } { } ] ?
[ 128 "integer*8" fortran-arg>c-args ] unit-test

[ B{ CHAR: h CHAR: e CHAR: l CHAR: l CHAR: o } { 5 } ]
[ "hello" "character*5" fortran-arg>c-args ] unit-test

little-endian? [ B{ 0 0 128 63 } { } ] [ B{ 63 128 0 0 } { } ] ?
[ 1.0 "real" fortran-arg>c-args ] unit-test

little-endian? [ B{ 0 0 128 63 0 0 0 64 } { } ] [ B{ 63 128 0 0 64 0 0 0 } { } ] ?
[ C{ 1.0 2.0 } "complex" fortran-arg>c-args ] unit-test

little-endian? [ B{ 0 0 0 0 0 0 240 63 } { } ] [ B{ 63 240 0 0 0 0 0 0 } { } ] ?
[ 1.0 "double-precision" fortran-arg>c-args ] unit-test

little-endian?
[ B{ 0 0 0 0 0 0 240 63 0 0 0 0 0 0 0 64 } { } ] 
[ B{ 63 240 0 0 0 0 0 0 64 0 0 0 0 0 0 0 } { } ] ?
[ C{ 1.0 2.0 } "double-complex" fortran-arg>c-args ] unit-test

[ B{ 1 0 0 0 2 0 0 0 } { } ]
[ B{ 1 0 0 0 2 0 0 0 } "integer(2)" fortran-arg>c-args ] unit-test

