! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.fortran alien.structs
alien.syntax arrays assocs kernel macros namespaces sequences
tools.test fry ;
IN: alien.fortran.tests

RECORD: FORTRAN_TEST_RECORD
    { "INTEGER"     "FOO" }
    { "REAL(2)"     "BAR" }
    { "CHARACTER*4" "BAS" } ;

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

[ "complex-float" ]
[ "complex" fortran-type>c-type ] unit-test

[ "complex-double" ]
[ "double-complex" fortran-type>c-type ] unit-test

[ "complex-float" ]
[ "complex*8" fortran-type>c-type ] unit-test

[ "complex-double" ]
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

[ "void" { "complex-float*" } ]
[ "complex" fortran-ret-type>c-type ] unit-test

[ "void" { "complex-double*" } ]
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

[ "void" { "complex-float*" "char*" "char*" "int*" "long" "long" } ]
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

! RECORD:

[ 16 ] [ "fortran_test_record" heap-size ] unit-test
[  0 ] [ "foo" "fortran_test_record" offset-of ] unit-test
[  4 ] [ "bar" "fortran_test_record" offset-of ] unit-test
[ 12 ] [ "bas" "fortran_test_record" offset-of ] unit-test

! fortran-invoke

: fortran-invoke-expansion ( return library function parameters -- quot )
    '[ _ _ _ _ fortran-invoke ] expand-macros ; inline

[ [
    ! [fortran-args>c-args]
    {
        [ {
            [ ascii string>alien ]
            [ <int> ]
            [ <float> ]
            [ <complex-float> ]
            [ 1 0 ? <short> ]
        } spread ]
        [ { [ length ] [ drop ] [ drop ] [ drop ] [ drop ] } spread ]
    } 5 ncleave
    ! [fortran-invoke]
    [ 
        "void" "foopack" "funtimes_"
        { "char*" "int*" "float*" "complex-float*" "short*" "long" }
        alien-invoke
    ] 6 nkeep
    ! [fortran-results>]
    {
        [ drop ]
        [ drop ]
        [ *float ]
        [ drop ]
        [ drop ]
        [ drop ]
    } spread
] ] [
    f "foopack" "FUNTIMES" { "CHARACTER*12" "INTEGER*8" "!REAL" "COMPLEX" "LOGICAL*2" }
    fortran-invoke-expansion
] unit-test

[ [
    ! [fortran-invoke]
    "double" "foopack" "fun_times__"
    { "float*" } 
    alien-invoke
] ] [
    "REAL" "foopack" "FUN_TIMES" { "REAL(*)" }
    fortran-invoke-expansion
] unit-test

[ [
    ! [<fortran-result>]
    [ "complex-float" <c-object> ] 1 ndip
    ! [fortran-invoke]
    [
        "void" "foopack" "fun_times__"
        { "complex-float*" "float*" } 
        alien-invoke
    ] 2 nkeep
    ! [fortran-results>]
    {
        [ *complex-float ]
        [ drop ]
    } spread
] ] [
    "COMPLEX" "foopack" "FUN_TIMES" { "REAL(*)" }
    fortran-invoke-expansion
] unit-test

[ [
    ! [<fortran-result>]
    [ 20 <byte-array> 20 ] 1 ndip
    ! [fortran-invoke]
    [
        "void" "foopack" "fun_times__"
        { "char*" "long" "float*" } 
        alien-invoke
    ] 3 nkeep
    ! [fortran-results>]
    {
        [ ]
        [ ascii alien>nstring ]
        [ drop ]
    } spread
] ] [
    "CHARACTER*20" "foopack" "FUN_TIMES" { }
    fortran-invoke-expansion
] unit-test

[ [
    ! [<fortran-result>]
    [ 10 <byte-array> 10 ] 2 ndip
    ! [fortran-args>c-args]
    {
        [ {
            [ ascii string>alien ]
            [ <float> ]
        } spread ]
        [ { [ length ] [ drop ] } spread ]
    } 2 ncleave
    ! [fortran-invoke]
    [
        "void" "foopack" "fun_times__"
        { "char*" "long" "char*" "float*" "long" } 
        alien-invoke
    ] 5 nkeep
    ! [fortran-results>]
    {
        [ ]
        [ ascii alien>nstring ]
        [ ]
        [ *float swap ]
        [ ascii alien>nstring ]
    } spread
] ] [
    "CHARACTER*10" "foopack" "FUN_TIMES" { "!CHARACTER*20" "!REAL" }
    fortran-invoke-expansion
] unit-test

