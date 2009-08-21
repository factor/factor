USING: layouts math tools.test ;
IN: system.tests

[ t ] [ cell integer? ] unit-test
[ t ] [ bootstrap-cell integer? ] unit-test

! Smoke test
[ t ] [ max-array-capacity cell-bits 2^ < ] unit-test
