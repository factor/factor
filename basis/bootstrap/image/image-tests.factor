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

{ 18 } [
    H{ } [ special-objects set emit-jit-data ] keep assoc-size
] unit-test

{ 95 } [
    50 <vector> [ bootstrapping-image set emit-image-header ] keep length
] unit-test

! emit-bignum
{ V{
    ! 33 bignum
    32 0 33
    ! -108 bignum
    32 1 108
} } [
    V{ } bootstrapping-image set
    33 emit-bignum
    -108 emit-bignum
    bootstrapping-image get
] unit-test

! prepare-object - what does this mean?
{ 269 } [
    V{ } clone bootstrapping-image set
    H{ } clone objects set
    55 >bignum prepare-object
] unit-test
