! Run from an ordinary image after the unchanged compiler/io bootstrap.
USING: accessors arrays classes.tuple combinators compiler compiler.test
io kernel math math.bitwise memory namespaces sequences system tools.test words ;
IN: cpu.hppa.optimizer-acceptance
: scalar-arithmetic ( a b -- result ) [ 13 * ] [ 7 * ] bi* + 3 + ;
: variable-shift ( value count -- result ) shift ;
: float-arithmetic ( a b -- result ) [ 1.25 * ] [ 0.5 * ] bi* + ;
: linked-leaf ( value -- result ) 17 + ;
: linked-call ( value -- result ) [ linked-leaf ] [ linked-leaf ] bi + ;
TUPLE: root-pair left right ;
C: <root-pair> root-pair
: allocated-root ( value -- result )
    dup 4 + <root-pair> [ drop gc ] keep [ left>> ] [ right>> ] bi + ;
{ scalar-arithmetic variable-shift float-arithmetic linked-leaf linked-call allocated-root } compile
{ t } [
    { scalar-arithmetic variable-shift float-arithmetic linked-leaf linked-call allocated-root }
    [ word-optimized? ] all?
] unit-test
{ 57 } [ 2 4 scalar-arithmetic ] unit-test
{ t t } [ 134217727 fixnum? -134217728 fixnum? ] unit-test
{ 805306358 } [ 134217727 -134217728 scalar-arithmetic ] unit-test
{ -6 2147483648 } [ -42 -3 variable-shift 1 31 variable-shift ] unit-test
{ 6.5 } [ 2.0 8.0 float-arithmetic ] unit-test
{ 48 } [ 7 linked-call ] unit-test
{ 18 } [ 7 allocated-root ] unit-test
test-failures get empty? t assert=
"Optimizing word arithmetic, calls, allocation and live GC roots passed on:" print
cpu name>> print
