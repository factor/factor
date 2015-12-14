USING: arrays assocs bootstrap.image.private kernel layouts math
math.bitwise namespaces sequences tools.test vectors ;
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

! emit-object
{ -96 } [
    V{ } clone bootstrapping-image set array [ ] emit-object
    data-base - 15 unmask bootstrap-cell /
] unit-test

! heap-size 10 header + 85 special objects
{ -95 } [
    V{ } clone bootstrapping-image set heap-size
    bootstrap-cell /
] unit-test

! here
{ -95 } [
    V{ } clone bootstrapping-image set here
    data-base - bootstrap-cell /
] unit-test

! here-as
{ -96 } [
    V{ } clone bootstrapping-image set array type-number here-as
    data-base - 15 unmask bootstrap-cell /
] unit-test

! prepare-object
{ -96 } [
    V{ } clone bootstrapping-image set
    H{ } clone objects set
    55 >bignum prepare-object
    data-base - 15 unmask bootstrap-cell /
] unit-test
