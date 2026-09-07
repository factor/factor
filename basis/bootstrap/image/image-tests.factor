USING: arrays assocs bootstrap.image.private endian fry grouping io
io.encodings.binary io.streams.byte-array kernel layouts math
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

{ f } [ 0.0 -0.0 eql? ] unit-test
{ f } [ { 0.0 } { -0.0 } eql? ] unit-test

{ t } [ 0x7ff8000000000001 bits>double dup eql? ] unit-test
{ t } [
    0x7ff8000000000001 bits>double
    0x7ff8000000000001 bits>double eql?
] unit-test
{ f } [
    0x7ff8000000000001 bits>double
    0x7ff8000000000002 bits>double eql?
] unit-test

: foo ( -- )
    ;

{ foo } [
    100 0 <array> [
        bootstrapping-image set \ foo 1 emit-special-object
    ] keep 11 swap nth
] unit-test

{ 17 } [
    H{ } [ special-objects set emit-jit-data ] keep assoc-size
] unit-test

{ 93 } [
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
{ -94 } [
    V{ } clone bootstrapping-image set array [ ] emit-object
    data-base - 15 unmask bootstrap-cell /
] unit-test

! heap-size 10 header + 83 special objects
{ -93 } [
    V{ } clone bootstrapping-image set heap-size
    bootstrap-cell /
] unit-test

! here
{ -93 } [
    V{ } clone bootstrapping-image set here
    data-base - bootstrap-cell /
] unit-test

! here-as
{ -94 } [
    V{ } clone bootstrapping-image set array type-number here-as
    data-base - 15 unmask bootstrap-cell /
] unit-test

! prepare-object
{ -94 } [
    V{ } clone bootstrapping-image set
    H{ } clone objects set
    55 >bignum prepare-object
    data-base - 15 unmask bootstrap-cell /
] unit-test

! The serialized cells use the target width and byte order, including
! negative values and unsigned values whose high bit is set.
: image-bytes ( cells cell-size big-endian? -- bytes )
    [
        bootstrap.image.private:big-endian set \ cell set
        binary [ (write-image) ] with-byte-writer
    ] with-scope ;

{ B{ } } [ { } 4 f image-bytes ] unit-test
{ B{ } } [ { } 8 t image-bytes ] unit-test

{ B{ 4 3 2 1 255 255 255 255 0 0 0 128 255 255 255 255 } } [
    { 0x01020304 -1 0x80000000 0xffffffff } 4 f image-bytes
] unit-test

{ B{ 1 2 3 4 255 255 255 255 128 0 0 0 255 255 255 255 } } [
    { 0x01020304 -1 0x80000000 0xffffffff } 4 t image-bytes
] unit-test

{ B{
    8 7 6 5 4 3 2 1 255 255 255 255 255 255 255 255
    0 0 0 0 0 0 0 128 255 255 255 255 255 255 255 255
} } [
    { 0x0102030405060708 -1 0x8000000000000000 0xffffffffffffffff }
    8 f image-bytes
] unit-test

{ B{
    1 2 3 4 5 6 7 8 255 255 255 255 255 255 255 255
    128 0 0 0 0 0 0 0 255 255 255 255 255 255 255 255
} } [
    { 0x0102030405060708 -1 0x8000000000000000 0xffffffffffffffff }
    8 t image-bytes
] unit-test

! Exercise both full buffers and a final partial buffer.
{ t } [
    16,387 <iota> dup 4 f image-bytes 4 <groups> [ le> ] map sequence=
] unit-test

{ t } [
    16,387 <iota> dup 4 t image-bytes 4 <groups> [ be> ] map sequence=
] unit-test

{ t } [
    8,195 <iota> dup 8 f image-bytes 8 <groups> [ le> ] map sequence=
] unit-test

{ t } [
    8,195 <iota> dup 8 t image-bytes 8 <groups> [ be> ] map sequence=
] unit-test

! #758: anonymous fry words, including ones referenced by other fry
! expansions, must survive generating a boot image from the new image.
{ t } [
    [
        H{ } clone objects set
        H{ } clone sub-primitives set
        [ '[ _ 2 '[ _ ] call ] ] first 1vector bootstrapping-image set
        emit-uninterned-words
        bootstrapping-image get [ fry-word? ] filter
        [ lookup-object integer? ] all?
    ] with-scope
] unit-test
