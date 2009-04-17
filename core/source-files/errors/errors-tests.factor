USING: assocs compiler.errors compiler.units definitions
namespaces source-files.errors tools.test words ;
IN: source-files.errors.tests

DEFER: forget-test

[ ] [ [ \ forget-test [ 1 ] (( -- )) define-declared ] with-compilation-unit ] unit-test
[ t ] [ \ forget-test compiler-errors get key? ] unit-test
[ ] [ [ \ forget-test forget ] with-compilation-unit ] unit-test
[ f ] [ \ forget-test compiler-errors get key? ] unit-test