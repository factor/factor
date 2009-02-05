USING: alien.fortran alien.syntax tools.test ;
IN: alien.fortran.tests

C-STRUCT: fortran_test_struct
    { "int" "foo" }
    { "float" "bar" }
    { "char[4]" "bas" } ;

! F-RECORD: fortran_test_record
!     { "integer" "foo" }
!     { "real" "bar" }
!     { "character*4" "bar" }

! fortran-name>symbol-name

[ "fun_" ] [ "FUN" fortran-name>symbol-name ] unit-test
[ "fun_times__" ] [ "Fun_Times" fortran-name>symbol-name ] unit-test

! fortran-type>c-type

[ "short" ]
[ "integer*2" fortran-type>c-type ] unit-test

[ "int" ]
[ "integer*4" fortran-type>c-type ] unit-test

[ "int" ]
[ "integer" fortran-type>c-type ] unit-test

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
[ "double precision" fortran-type>c-type ] unit-test

[ "float" ]
[ "real*4" fortran-type>c-type ] unit-test

[ "double" ]
[ "real*8" fortran-type>c-type ] unit-test

[ "(fortran-complex)" ]
[ "complex" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "double complex" fortran-type>c-type ] unit-test

[ "(fortran-complex)" ]
[ "complex*8" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "complex*16" fortran-type>c-type ] unit-test

[ "(fortran-double-complex)" ]
[ "complex*16" fortran-type>c-type ] unit-test

[ "fortran_test_struct" ]
[ "fortran_test_struct" fortran-type>c-type ] unit-test

[ "fortran_test_record" ]
[ "fortran_test_record" fortran-type>c-type ] unit-test

! fortran-arg-type>c-type

[ "int*" { } ]
[ "integer" fortran-arg-type>c-type ] unit-test

[ "int*" { } ]
[ "integer(3)" fortran-arg-type>c-type ] unit-test

[ "int*" { } ]
[ "integer(*)" fortran-arg-type>c-type ] unit-test

[ "fortran_test_struct*" { } ]
[ "fortran_test_struct" fortran-arg-type>c-type ] unit-test

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
[ "double precision" fortran-ret-type>c-type ] unit-test

[ "void" { "(fortran-complex)*" } ]
[ "complex" fortran-ret-type>c-type ] unit-test

[ "void" { "(fortran-double-complex)*" } ]
[ "double complex" fortran-ret-type>c-type ] unit-test

[ "void" { "int*" } ]
[ "integer(*)" fortran-ret-type>c-type ] unit-test

[ "void" { "fortran_test_record*" } ]
[ "fortran_test_record" fortran-ret-type>c-type ] unit-test

