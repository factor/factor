USING: fry kernel locals math namespaces sequences stack-checker
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

! #241: each must not erase a callable in its untouched caller prefix.
: invoke ( quot -- ) call ; inline
: after-each ( quot -- ) [ { 1 2 3 } [ drop ] each call ] invoke ; inline
: known-after-each ( -- n ) [ 42 ] after-each ;
{ 42 } [ known-after-each ] unit-test
{ 0 1 } [ [ 42 ] after-each ] must-infer-as

:: captured-after-each ( n -- n ) n '[ _ 1 + ] after-each ;
{ 42 } [ 41 captured-after-each ] unit-test

: composed-after-each ( -- n ) [ 40 ] [ 2 + ] compose after-each ;
{ 42 } [ composed-after-each ] unit-test
{ 1 1 } [ [ reverse ] swap [ reverse ] map swap call ] must-infer-as

! A touched prefix must not be restored to its value at recursive entry.
: replace-prefix ( ... n -- ... n )
    dup zero? [ [ drop [ 2 ] ] dip ]
    [ 1 - replace-prefix ] if ; inline recursive

[ [ [ 1 ] 3 replace-prefix drop call ] infer ]
[ bad-macro-input? ] must-fail-with
{ 2 } [ [ 1 ] 3 replace-prefix drop call( -- n ) ] unit-test
