USING: kernel math namespaces sequences stack-checker
stack-checker.errors tools.test ;
IN: stack-checker.inlining.tests

! #165: an inline recursive callback must not appear to touch the whole stack.
: countdown ( n -- n ) dup zero? [ ] [ 1 - countdown ] if ; inline recursive
: invoke-one ( quot: ( x -- x ) -- ) call ; inline

{ 2 2 } [ [ ] 2dip [ countdown ] invoke-one ] must-infer-as
{ 99 0 } [ 99 3 [ countdown ] invoke-one ] unit-test

! #2241: the loop does not consume the variable beneath the callback's input.
SYMBOL: counter
: with-value-change ( var quot: ( value -- value' ) -- )
    [ dup get ] dip call swap set ; inline

{ 0 0 } [ counter [ { 1 2 } [ drop ] each 1 + ] with-value-change ] must-infer-as
{ 42 } [
    41 counter [ counter [ { 1 2 } [ drop ] each 1 + ] with-value-change
    counter get ] with-variable
] unit-test

{ 2 2 } [ [ ] 2dip [ { 1 2 } [ drop 1 + ] each ] invoke-one ] must-infer-as
{ 99 42 } [ 99 40 [ { 1 2 } [ drop 1 + ] each ] invoke-one ] unit-test

! Real accesses below a callback's declared inputs must still be rejected.
[ [ [ ] 2dip [ { 1 2 } [ drop swap ] each ] invoke-one ] infer ]
[ unbalanced-branches-error? ] must-fail-with

: deep-countdown ( ... n -- ... n )
    dup zero? [ ] [ [ swap ] dip 1 - deep-countdown ] if ; inline recursive

[ [ [ ] 3dip [ deep-countdown ] invoke-one ] infer ]
[ unbalanced-branches-error? ] must-fail-with
{ 2 1 0 } [ 1 2 3 deep-countdown ] unit-test

! A recursive call crossing a new callback boundary can reach deeper accesses
! in another branch of the recursive body.
: callback-recursion ( ... n -- ... n )
    dup zero? [ [ 1 + ] dip ]
    [ 1 - [ callback-recursion ] invoke-one ] if ; inline recursive

[ [ [ ] 2dip callback-recursion ] infer ]
[ unbalanced-branches-error? ] must-fail-with
FORGET: callback-recursion
