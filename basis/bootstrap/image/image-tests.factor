USING: arrays assocs bootstrap.image.private kernel math namespaces
sequences tools.test vectors ;
IN: bootstrap.image.tests

{ f } [ { 1 2 3 } [ 1 2 3 ] eql? ] unit-test

{ t } [ [ 1 2 3 ] [ 1 2 3 ] eql? ] unit-test

{ f } [ [ 2drop 0 ] [ 2drop 0.0 ] eql? ] unit-test

{ t } [ [ 2drop 0 ] [ 2drop 0 ] eql? ] unit-test

{ f } [ \ + [ 2drop 0 ] eql? ] unit-test

{ f } [ 3 [ 0 1 2 ] eql? ] unit-test

{ f } [ 3 3.0 eql? ] unit-test

{ t } [ 4.0 4.0 eql? ] unit-test

: foo ( -- )
    ;

{ foo } [
    100 0 <array> [
        bootstrapping-image set \ foo 1 emit-special-object
    ] keep 11 swap nth
] unit-test

{ 20 } [
    H{ } [ special-objects set emit-jit-data ] keep assoc-size
] unit-test

{ 90 } [
    50 <vector> [ bootstrapping-image set emit-image-header ] keep length
] unit-test
