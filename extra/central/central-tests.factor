USING: accessors central destructors kernel math tools.test ;

IN: scratchpad

CENTRAL: test-central

[ 3 ] [ 3 [ test-central ] with-test-central ] unit-test

TUPLE: test-disp-cent value disposed ;

! A phony destructor that adds 1 to the value so we can make sure it got called.
M: test-disp-cent dispose* dup value>> 1+ >>value drop ;

DISPOSABLE-CENTRAL: t-d-c

: test-t-d-c ( -- n )
    test-disp-cent new 3 >>value [ t-d-c ] with-t-d-c value>> ;

[ 4 ] [ test-t-d-c ] unit-test