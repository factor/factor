! (c) 2009 Joe Groff, see BSD license
USING: accessors alien alien.c-types alien.complex
alien.data alien.fortran alien.fortran.private alien.strings
classes.struct arrays assocs byte-arrays combinators fry
generalizations io.encodings.ascii kernel macros
macros.expander namespaces sequences shuffle tools.test vocabs.parser ;
QUALIFIED-WITH: alien.c-types c
IN: alien.fortran.tests

<< intel-unix-abi "(alien.fortran-tests)" (add-fortran-library) >>
LIBRARY: (alien.fortran-tests)
STRUCT: fortran_test_record
    { FOO int }
    { BAR double[2] }
    { BAS char[4] } ;

intel-unix-abi fortran-abi [

    ! fortran-name>symbol-name

    [ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
    [ "fun_times_" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
    [ "funtimes__" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

    ! fortran-type>c-type

    [ c:short ]
    [ "integer*2" fortran-type>c-type ] unit-test

    [ c:int ]
    [ "integer*4" fortran-type>c-type ] unit-test

    [ c:int ]
    [ "INTEGER" fortran-type>c-type ] unit-test

    [ c:longlong ]
    [ "iNteger*8" fortran-type>c-type ] unit-test

    [ { c:int 0 } ]
    [ "integer(*)" fortran-type>c-type ] unit-test

    [ { c:int 0 } ]
    [ "integer(3,*)" fortran-type>c-type ] unit-test

    [ { c:int 3 } ]
    [ "integer(3)" fortran-type>c-type ] unit-test

    [ { c:int 6 } ]
    [ "integer(3,2)" fortran-type>c-type ] unit-test

    [ { c:int 24 } ]
    [ "integer(4,3,2)" fortran-type>c-type ] unit-test

    [ c:char ]
    [ "character" fortran-type>c-type ] unit-test

    [ c:char ]
    [ "character*1" fortran-type>c-type ] unit-test

    [ { c:char 17 } ]
    [ "character*17" fortran-type>c-type ] unit-test

    [ { c:char 17 } ]
    [ "character(17)" fortran-type>c-type ] unit-test

    [ c:int ]
    [ "logical" fortran-type>c-type ] unit-test

    [ c:float ]
    [ "real" fortran-type>c-type ] unit-test

    [ c:double ]
    [ "double-precision" fortran-type>c-type ] unit-test

    [ c:float ]
    [ "real*4" fortran-type>c-type ] unit-test

    [ c:double ]
    [ "real*8" fortran-type>c-type ] unit-test

    [ complex-float ]
    [ "complex" fortran-type>c-type ] unit-test

    [ complex-double ]
    [ "double-complex" fortran-type>c-type ] unit-test

    [ complex-float ]
    [ "complex*8" fortran-type>c-type ] unit-test

    [ complex-double ]
    [ "complex*16" fortran-type>c-type ] unit-test

    [ fortran_test_record ]
    [
        [
            "alien.fortran.tests" use-vocab
            "fortran_test_record" fortran-type>c-type
        ] with-manifest
    ] unit-test

    ! fortran-arg-type>c-type

    [ c:void* { } ]
    [ "integer" fortran-arg-type>c-type ] unit-test

    [ c:void* { } ]
    [ "integer(3)" fortran-arg-type>c-type ] unit-test

    [ c:void* { } ]
    [ "integer(*)" fortran-arg-type>c-type ] unit-test

    [ c:void* { } ]
    [
        [
            "alien.fortran.tests" use-vocab
            "fortran_test_record" fortran-arg-type>c-type
        ] with-manifest
    ] unit-test

    [ c:char* { } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ c:char* { } ]
    [ "character(1)" fortran-arg-type>c-type ] unit-test

    [ c:char* { long } ]
    [ "character(17)" fortran-arg-type>c-type ] unit-test

    ! fortran-ret-type>c-type

    [ c:char { } ]
    [ "character(1)" fortran-ret-type>c-type ] unit-test

    [ c:void { c:char* long } ]
    [ "character(17)" fortran-ret-type>c-type ] unit-test

    [ c:int { } ]
    [ "integer" fortran-ret-type>c-type ] unit-test

    [ c:int { } ]
    [ "logical" fortran-ret-type>c-type ] unit-test

    [ c:float { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

    [ c:double { } ]
    [ "double-precision" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [ "complex" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [ "double-complex" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [ "integer(*)" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [
        [
            "alien.fortran.tests" use-vocab
            "fortran_test_record" fortran-ret-type>c-type
        ] with-manifest
    ] unit-test

    ! fortran-sig>c-sig

    [ c:float { c:void* c:char* c:void* c:void* c:long } ]
    [ "real" { "integer" "character*17" "real" "real*8" } fortran-sig>c-sig ]
    unit-test

    [ c:char { c:char* c:char* c:void* c:long } ]
    [ "character(1)" { "character*17" "character" "integer" } fortran-sig>c-sig ]
    unit-test

    [ c:void { c:char* c:long c:char* c:char* c:void* c:long } ]
    [ "character*18" { "character*17" "character" "integer" } fortran-sig>c-sig ]
    unit-test

    [ c:void { c:void* c:char* c:char* c:void* c:long } ]
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
            c:void "funpack" "funtimes_"
            { c:char* c:void* c:void* c:void* c:void* c:long }
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
        [ c:float "funpack" "fun_times_" { void* } alien-invoke ]
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
        [ complex-float <c-object> ] 1 ndip
        ! [fortran-args>c-args]
        { [ { [ ] } spread ] [ { [ drop ] } spread ] } 1 ncleave
        ! [fortran-invoke]
        [
            c:void "funpack" "fun_times_"
            { void* void* } 
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
            c:void "funpack" "fun_times_"
            { c:char* long } 
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
            c:void "funpack" "fun_times_"
            { c:char* long c:char* c:void* c:char* c:long c:long } 
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

    [ { c:char 1 } ]
    [ "character(1)" fortran-type>c-type ] unit-test

    [ c:char* { c:long } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ c:void { c:char* c:long } ]
    [ "character" fortran-ret-type>c-type ] unit-test

    [ c:double { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ c:void { void* } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

    [ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
    [ "fun_times__" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test
    [ "funtimes___" ] [ "FunTimes_" fortran-name>symbol-name ] unit-test

] with-variable

gfortran-abi fortran-abi [

    [ c:float { } ]
    [ "real" fortran-ret-type>c-type ] unit-test

    [ c:void { void* } ]
    [ "real(*)" fortran-ret-type>c-type ] unit-test

    [ complex-float { } ]
    [ "complex" fortran-ret-type>c-type ] unit-test

    [ complex-double { } ]
    [ "double-complex" fortran-ret-type>c-type ] unit-test

    [ { char 1 } ]
    [ "character(1)" fortran-type>c-type ] unit-test

    [ c:char* { c:long } ]
    [ "character" fortran-arg-type>c-type ] unit-test

    [ c:void { c:char* c:long } ]
    [ "character" fortran-ret-type>c-type ] unit-test

    [ complex-float { } ]
    [ "complex" fortran-ret-type>c-type ] unit-test

    [ complex-double { } ]
    [ "double-complex" fortran-ret-type>c-type ] unit-test

    [ c:void { c:void* } ]
    [ "double-complex(3)" fortran-ret-type>c-type ] unit-test

] with-variable
