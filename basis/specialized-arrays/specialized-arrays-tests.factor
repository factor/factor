IN: specialized-arrays.tests
USING: tools.test specialized-arrays sequences
specialized-arrays.int speicalized-arrays.bool ;

[ t ] [ { 1 2 3 } >int-array int-array? ] unit-test

[ t ] [ int-array{ 1 2 3 } int-array? ] unit-test

[ 2 ] [ int-array{ 1 2 3 } second ] unit-test

[ t ] [ { t f t } >bool-array underlying>> { 1 0 1 } >int-array underlying>> = ] unit-test
