USING: accessors compiler compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.live-intervals compiler.tree.propagation.info compiler.utilities kernel kernel.private layouts math.order sequences math math.intervals namespaces sets stack-checker.dependencies tools.test ;
IN: math.intervals.integer-only.tests

{ t } [ 2 4 [a,b] 3 8 [a,b] interval+ 5 12 [a,b] = ] unit-test
{ t } [ -4 3 [a,b] 0 9 [a,b] interval-intersect 0 3 [a,b] = ] unit-test
{ t } [ 2 7 [a,b] full-interval interval-intersect 2 7 [a,b] = ] unit-test
{ t } [ 4 9 [a,b] integral-closure 4 9 [a,b] = ] unit-test
: integer-range-result ( a b -- c ) * 5 + ;
{ 45 } [ 20 2 integer-range-result ] unit-test
{ t } [
    float 2 7 [a,b] <class/interval-info> interval>>
    floating-point-supported? [ 2 7 [a,b] = ] [ full-interval? ] if
] unit-test
{ t } [ fixnum 2 7 [a,b] <class/interval-info> interval>> 2 7 [a,b] = ] unit-test

{ t } [
    0 "opaque-zero-bits" namespaces:set
    <compiler-conditional-dependencies> conditional-dependencies [
        "opaque-zero-bits" get bits>double float t add-depends-on-instance-predicate
        "opaque-zero-bits" get bits>double float t add-depends-on-instance-predicate
        conditional-dependencies get members
        [ [ satisfied? ] all? ]
        [ length floating-point-supported? [ 1 ] [ 2 ] if = ] bi and
    ] with-variable
] unit-test

{ t } [
    most-positive-fixnum allocation-infinity <
] unit-test

! These are optimization premises, so an unknown range proves neither sign.
{ f f } [ full-interval [ interval-nonnegative? ] [ interval-nonpositive? ] bi ] unit-test
{ f t } [ -4 -2 [a,b] [ interval-nonnegative? ] [ interval-nonpositive? ] bi ] unit-test
{ t f } [ 2 4 [a,b] [ interval-nonnegative? ] [ interval-nonpositive? ] bi ] unit-test
{ 4 -4 -4 1 } [ 16 -2 shift -16 -2 shift -1 2 shift -5 2 mod ] unit-test

floating-point-supported? [
    { t } [ allocation-infinity integer? ] unit-test
    { t } [ most-negative-fixnum compiler-position-negative-infinity > ] unit-test
    { t } [
        H{ { 0 0x100000000000000000000 } }
        compiler-spill-infinity 0x100000000000000000000 >
    ] unit-test
    { t } [
        T{ sync-point { n 33 } } interval/sync-point-key
        rest [ integer? ] all?
    ] unit-test
    { t } [ 0 [a,inf] interval-nonnegative? ] unit-test
    { t } [ 0 [-inf,b] interval-nonpositive? ] unit-test
    { t } [ [0,inf] interval-nonnegative? ] unit-test
    { t } [ 0.0 [a,a] full-interval? ] unit-test
    { t t } [
        0.0 <literal-info> dup literal>> float?
        swap interval>> full-interval?
    ] unit-test
    { t } [ 1 [a,a] 2 [a,a] interval/f full-interval? ] unit-test
] unless
