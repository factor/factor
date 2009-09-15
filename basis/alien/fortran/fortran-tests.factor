! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.complex
alien.fortran alien.fortran.private alien.strings classes.struct
arrays assocs byte-arrays combinators fry
generalizations io.encodings.ascii kernel macros
macros.expander namespaces sequences shuffle tools.test ;
IN: alien.fortran.tests

<< intel-unix-abi "(alien.fortran-tests)" (add-fortran-library) >>
LIBRARY: (alien.fortran-tests)
STRUCT: FORTRAN_TEST_RECORD
    { FOO int }
    { BAR double[2] }
    { BAS char[4] } ;

intel-unix-abi fortran-abi [

    ! fortran-name>symbol-name

    [ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
    [ "fun_times_" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
    [ "funtimes__" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

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

    [ "char" ]
    [ "character" fortran-type>c-type ] unit-test

    [ "char" ]
    [ "character*1" fortran-type>c-type ] unit-test

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

    [ "char*" { } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ "char*" { } ]
    [ "character(1)" fortran-arg-type>c-type ] unit-test

    [ "char*" { "long" } ]
    [ "character(17)" fortran-arg-type>c-type ] unit-test

    ! fortran-ret-type>c-type

    [ "char" { } ]
    [ "character(1)" fortran-ret-type>c-type ] unit-test

    [ "void" { "char*" "long" } ]
    [ "character(17)" fortran-ret-type>c-type ] unit-test

    [ "int" { } ]
    [ "integer" fortran-ret-type>c-type ] unit-test

    [ "int" { } ]
    [ "logical" fortran-ret-type>c-type ] unit-test

    [ "float" { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ "void" { "float*" } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

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

    [ "float" { "int*" "char*" "float*" "double*" "long" } ]
    [ "real" { "integer" "character*17" "real" "real*8" } fortran-sig>c-sig ]
    unit-test

    [ "char" { "char*" "char*" "int*" "long" } ]
    [ "character(1)" { "character*17" "character" "integer" } fortran-sig>c-sig ]
    unit-test

    [ "void" { "char*" "long" "char*" "char*" "int*" "long" } ]
    [ "character*18" { "character*17" "character" "integer" } fortran-sig>c-sig ]
    unit-test

    [ "void" { "complex-float*" "char*" "char*" "int*" "long" } ]
    [ "complex" { "character*17" "character" "integer" } fortran-sig>c-sig ]
    unit-test

    ! (fortran-invoke)

    [ [
        ! [fortran-args>c-args]
        {
            [ {
                [ ascii string>alien ]
                [ <longlong> ]
                [ <float> ]
                [ <complex-float> ]
                [ 1 0 ? <short> ]
            } spread ]
            [ { [ length ] [ drop ] [ drop ] [ drop ] [ drop ] } spread ]
        } 5 ncleave
        ! [fortran-invoke]
        [ 
            "void" "funpack" "funtimes_"
            { "char*" "longlong*" "float*" "complex-float*" "short*" "long" }
            alien-invoke
        ] 6 nkeep
        ! [fortran-results>]
        shuffle( aa ba ca da ea ab -- aa ab ba ca da ea ) 
        {
            [ drop ]
            [ drop ]
            [ drop ]
            [ *float ]
            [ drop ]
            [ drop ]
        } spread
    ] ] [
        f "funpack" "FUNTIMES" { "CHARACTER*12" "INTEGER*8" "!REAL" "COMPLEX" "LOGICAL*2" }
        (fortran-invoke)
    ] unit-test

    [ [
        ! [fortran-args>c-args]
        {
            [ { [ ] } spread ]
            [ { [ drop ] } spread ]
        } 1 ncleave
        ! [fortran-invoke]
        [ "float" "funpack" "fun_times_" { "float*" } alien-invoke ]
        1 nkeep
        ! [fortran-results>]
        shuffle( reta aa -- reta aa ) 
        { [ ] [ drop ] } spread
    ] ] [
        "REAL" "funpack" "FUN_TIMES" { "REAL(*)" }
        (fortran-invoke)
    ] unit-test

    [ [
        ! [<fortran-result>]
        [ "complex-float" <c-object> ] 1 ndip
        ! [fortran-args>c-args]
        { [ { [ ] } spread ] [ { [ drop ] } spread ] } 1 ncleave
        ! [fortran-invoke]
        [
            "void" "funpack" "fun_times_"
            { "complex-float*" "float*" } 
            alien-invoke
        ] 2 nkeep
        ! [fortran-results>]
        shuffle( reta aa -- reta aa )
        { [ *complex-float ] [ drop ] } spread
    ] ] [
        "COMPLEX" "funpack" "FUN_TIMES" { "REAL(*)" }
        (fortran-invoke)
    ] unit-test

    [ [
        ! [<fortran-result>]
        [ 20 <byte-array> 20 ] 0 ndip
        ! [fortran-invoke]
        [
            "void" "funpack" "fun_times_"
            { "char*" "long" } 
            alien-invoke
        ] 2 nkeep
        ! [fortran-results>]
        shuffle( reta retb -- reta retb ) 
        { [ ] [ ascii alien>nstring ] } spread
    ] ] [
        "CHARACTER*20" "funpack" "FUN_TIMES" { }
        (fortran-invoke)
    ] unit-test

    [ [
        ! [<fortran-result>]
        [ 10 <byte-array> 10 ] 3 ndip
        ! [fortran-args>c-args]
        {
            [ {
                [ ascii string>alien ]
                [ <float> ]
                [ ascii string>alien ]
            } spread ]
            [ { [ length ] [ drop ] [ length ] } spread ]
        } 3 ncleave
        ! [fortran-invoke]
        [
            "void" "funpack" "fun_times_"
            { "char*" "long" "char*" "float*" "char*" "long" "long" } 
            alien-invoke
        ] 7 nkeep
        ! [fortran-results>]
        shuffle( reta retb aa ba ca ab cb -- reta retb aa ab ba ca cb ) 
        {
            [ ]
            [ ascii alien>nstring ]
            [ ]
            [ ascii alien>nstring ]
            [ *float ]
            [ ]
            [ ascii alien>nstring ]
        } spread
    ] ] [
        "CHARACTER*10" "funpack" "FUN_TIMES" { "!CHARACTER*20" "!REAL" "!CHARACTER*30" }
        (fortran-invoke)
    ] unit-test

] with-variable ! intel-unix-abi

intel-windows-abi fortran-abi [

    [ "FUN" ] [ "FUN" fortran-name>symbol-name ] unit-test
    [ "FUN_TIMES" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
    [ "FUNTIMES_" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

] with-variable

f2c-abi fortran-abi [

    [ "char[1]" ]
    [ "character(1)" fortran-type>c-type ] unit-test

    [ "char*" { "long" } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ "void" { "char*" "long" } ]
    [ "character" fortran-ret-type>c-type ] unit-test

    [ "double" { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ "void" { "float*" } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

    [ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
    [ "fun_times__" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
    [ "funtimes___" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

] with-variable

gfortran-abi fortran-abi [

    [ "float" { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ "void" { "float*" } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

    [ "complex-float" { } ]
    [ "complex" fortran-ret-type>c-type ] unit-test

    [ "complex-double" { } ]
    [ "double-complex" fortran-ret-type>c-type ] unit-test

    [ "char[1]" ]
    [ "character(1)" fortran-type>c-type ] unit-test

    [ "char*" { "long" } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ "void" { "char*" "long" } ]
    [ "character" fortran-ret-type>c-type ] unit-test

    [ "complex-float" { } ]
    [ "complex" fortran-ret-type>c-type ] unit-test

    [ "complex-double" { } ]
    [ "double-complex" fortran-ret-type>c-type ] unit-test

    [ "void" { "complex-double*" } ]
    [ "double-complex(3)" fortran-ret-type>c-type ] unit-test

] with-variable
