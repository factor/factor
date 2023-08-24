USING: accessors alien alien.c-types alien.data arrays assocs
combinators combinators.short-circuit compiler.tree
compiler.tree.builder compiler.tree.checker compiler.tree.cleanup
compiler.tree.combinators compiler.tree.debugger
compiler.tree.normalization compiler.tree.propagation
compiler.tree.propagation.info generalizations grouping hashtables
io.encodings io.encodings.ascii io.encodings.utf8 kernel
kernel.private layouts math math.functions math.intervals math.order
math.partial-dispatch math.private prettyprint quotations sequences
sequences.private slots slots.private sorting.private tools.test
vectors ;
FROM: math => float ;
QUALIFIED-WITH: alien.c-types c
IN: compiler.tree.cleanup.tests

{ t } [ [ [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

{ f } [ [ f [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

{ f } [ [ { array } declare [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

{ t } [ [ { sequence } declare [ 1 ] [ 2 ] if ] cleaned-up-tree [ #if? ] contains-node? ] unit-test

: recursive-test ( a -- b ) dup [ not recursive-test ] when ; inline recursive

{ t } [ [ recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

{ f } [ [ f recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

{ t } [ [ t recursive-test ] cleaned-up-tree [ #recursive? ] contains-node? ] unit-test

{ f } [
    [ { integer } declare >fixnum ]
    \ >fixnum inlined?
] unit-test

GENERIC: mynot ( x -- y )

M: f mynot drop t ; inline

M: object mynot drop f ; inline

GENERIC: detect-f ( x -- y )

M: f detect-f ; inline

{ t } [
    [ dup [ mynot ] [ ] if detect-f ] \ detect-f inlined?
] unit-test

GENERIC: xyz ( n -- n )

M: integer xyz ; inline

M: object xyz ; inline

{ t } [
    [ { integer } declare xyz ] \ xyz inlined?
] unit-test

{ t } [
    [ dup fixnum? [ xyz ] [ drop "hi" ] if ]
    \ xyz inlined?
] unit-test

: (fx-repeat) ( i n quot: ( i -- i ) -- )
    2over fixnum>= [
        3drop
    ] [
        [ swap [ call 1 fixnum+fast ] dip ] keep (fx-repeat)
    ] if ; inline recursive

: fx-repeat ( n quot -- )
    0 -rot (fx-repeat) ; inline

! The + should be optimized into fixnum+, if it was not, then
! the type of the loop index was not inferred correctly
{ t } [
    [ [ dup 2 + drop ] fx-repeat ] \ + inlined?
] unit-test

: (i-repeat) ( i n quot: ( i -- i ) -- )
    2over dup xyz drop >= [
        3drop
    ] [
        [ swap [ call 1 + ] dip ] keep (i-repeat)
    ] if ; inline recursive

: i-repeat ( n quot -- ) [ { integer } declare ] dip 0 -rot (i-repeat) ; inline

{ t } [
    [ [ dup xyz drop ] i-repeat ] \ xyz inlined?
] unit-test

{ t } [
    [ { fixnum } declare dup 100 >= [ 1 + ] unless ] \ fixnum+ inlined?
] unit-test

{ t } [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

{ t } [
    [ { fixnum fixnum } declare dupd < [ 1 + 1 + ] when ]
    \ + inlined?
] unit-test

{ t } [
    [ { fixnum } declare [ ] times ] \ >= inlined?
] unit-test

{ t } [
    [ { fixnum } declare [ ] times ] \ + inlined?
] unit-test

{ t } [
    [ { fixnum } declare [ ] times ] \ fixnum+ inlined?
] unit-test

{ t } [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ + inlined?
] unit-test

{ f } [
    [ { integer fixnum } declare dupd < [ 1 + ] when ]
    \ +-integer-fixnum inlined?
] unit-test

{ t } [
    [
        [ no-cond ] 1
        [ 1array dup quotation? [ >quotation ] unless ] times
    ] \ quotation? inlined?
] unit-test

{ t } [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ + inlined?
] unit-test
{ f } [
    [
        1000000000000000000000000000000000 [ ] times
    ] \ +-integer-fixnum inlined?
] unit-test

{ f } [
    [ { bignum } declare [ ] times ]
    \ +-integer-fixnum inlined?
] unit-test

{ t } [
    [ { array-capacity } declare 0 < ] \ < inlined?
] unit-test

{ t } [
    [ { array-capacity } declare 0 < ] \ fixnum< inlined?
] unit-test

{ t } [
    [ { array-capacity } declare 1 fixnum- ] \ fixnum- inlined?
] unit-test

GENERIC: annotate-entry-test-1 ( x -- )

M: fixnum annotate-entry-test-1 drop ;

: (annotate-entry-test-2) ( from to -- )
    2dup >= [
        2drop
    ] [
        [ dup annotate-entry-test-1 1 + ] dip (annotate-entry-test-2)
    ] if ; inline recursive

: annotate-entry-test-2 ( from to -- obj ) 0 -rot (annotate-entry-test-2) ; inline

{ f } [
    [ { bignum } declare annotate-entry-test-2 ]
    \ annotate-entry-test-1 inlined?
] unit-test

{ t } [
    [ { float } declare 10 [ 2.3 * ] times >float ]
    \ >float inlined?
] unit-test

GENERIC: detect-float ( a -- b )

M: float detect-float ;

{ t } [
    [ { real float } declare + detect-float ]
    \ detect-float inlined?
] unit-test

{ t } [
    [ { float real } declare + detect-float ]
    \ detect-float inlined?
] unit-test

{ f } [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    \ fixnum-shift-fast inlined?
] unit-test

{ t } [
    [ { fixnum fixnum } declare 7 bitand neg shift ]
    { shift fixnum-shift } inlined?
] unit-test

{ t } [
    [ { fixnum fixnum } declare 1 swap 7 bitand shift ]
    { shift fixnum-shift } inlined?
] unit-test

{ f } [
    [ { fixnum fixnum } declare 1 swap 7 bitand shift ]
    { fixnum-shift-fast } inlined?
] unit-test

{ t } [
    [ 1 swap 7 bitand shift ]
    { shift fixnum-shift } inlined?
] unit-test

32-bit? [
    [ t ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ shift inlined?
    ] unit-test

    [ f ] [
        [ { fixnum fixnum } declare 1 swap 31 bitand shift ]
        \ fixnum-shift inlined?
    ] unit-test
] when

{ t } [
    [ B{ 1 0 } c:short deref 0 number= ]
    \ number= inlined?
] unit-test

{ t } [
    [ B{ 1 0 } c:short deref 0 { number number } declare number= ]
    \ number= inlined?
] unit-test

{ t } [
    [ B{ 1 0 } c:short deref 0 = ]
    \ number= inlined?
] unit-test

{ t } [
    [ B{ 1 0 } c:short deref dup number? [ 0 number= ] [ drop f ] if ]
    \ number= inlined?
] unit-test

{ t } [
    [ 0xff bitand 0 0xff between? ]
    \ >= inlined?
] unit-test

{ t } [
    [ 0xff swap 0xff bitand >= ]
    \ >= inlined?
] unit-test

{ t } [
    [ { vector } declare nth-unsafe ] \ nth-unsafe inlined?
] unit-test

{ t } [
    [
        dup integer? [
            dup fixnum? [
                1 +
            ] [
                2 +
            ] if
        ] when
    ] \ + inlined?
] unit-test

: rec ( a -- b )
    dup 0 > [ 1 - rec ] when ; inline recursive

{ t } [
    [ { fixnum } declare rec 1 + ]
    { > - + } inlined?
] unit-test

: fib ( m -- n )
    dup 2 < [ drop 1 ] [ dup 1 - fib swap 2 - fib + ] if ; inline recursive

{ t } [
    [ 27.0 fib ] { < - + } inlined?
] unit-test

{ f } [
    [ 27.0 fib ] { +-integer-integer } inlined?
] unit-test

{ t } [
    [ 27 fib ] { < - + } inlined?
] unit-test

{ t } [
    [ 27 >bignum fib ] { < - + } inlined?
] unit-test

{ f } [
    [ 27/2 fib ] { < - } inlined?
] unit-test

{ t } [
    [ 10 [ -1 shift ] times ] \ shift inlined?
] unit-test

{ f } [
    [ { fixnum } declare 1048575 fixnum-bitand 524288 fixnum- ]
    \ fixnum-bitand inlined?
] unit-test

{ t } [
    [ { fixnum } declare [ drop ] each-integer ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

{ t } [
    [ { fixnum } declare <iota> [ drop ] each ]
    { < <-integer-fixnum +-integer-fixnum + } inlined?
] unit-test

{ t } [
    [ { fixnum } declare <iota> 0 [ + ] reduce ]
    { < <-integer-fixnum nth-unsafe } inlined?
] unit-test

{ f } [
    [ { fixnum } declare <iota> 0 [ + ] reduce ]
    \ +-integer-fixnum inlined?
] unit-test

{ t } [
    [
        { integer } declare <iota> [ ] map
    ] \ integer>fixnum inlined?
] unit-test

{ f } [
    [
        { integer } declare { } set-nth-unsafe
    ] \ integer>fixnum inlined?
] unit-test

{ f } [
    [
        { integer } declare 1 + { } set-nth-unsafe
    ] \ >fixnum inlined?
] unit-test

{ t } [
    [
        { array } declare length
        1 + dup 100 fixnum> [ 1 fixnum+ ] when
    ] \ fixnum+ inlined?
] unit-test

{ t } [
    [ [ resize-array ] keep length ] \ length inlined?
] unit-test

{ t } [
    [ dup 0 > [ sqrt ] when ] \ sqrt inlined?
] unit-test

{ t } [
    [ { utf8 } declare decode-char ] \ decode-char inlined?
] unit-test

{ t } [
    [ { ascii } declare decode-char ] \ decode-char inlined?
] unit-test

{ t } [ [ { 1 2 } length ] { length length>> slot } inlined? ] unit-test

{ t } [
    [
        { integer } declare <iota> [ 0 >= ] map
    ] { >= fixnum>= } inlined?
] unit-test

{ } [
    [
        4 pick array-capacity?
        [ set-slot ] [ \ array-capacity 2nip bad-slot-value ] if
    ] cleaned-up-tree drop
] unit-test

{ } [
    [ { merge-state } declare accum>> 0 >>length ] cleaned-up-tree drop
] unit-test

{ } [
    [
        [ "X" throw ]
        [ dupd dup -1 < [ 0 >= [ ] [ "X" throw ] if ] [ drop ] if ]
        if
    ] cleaned-up-tree drop
] unit-test

{ t } [
    [ [ 2array ] [ 0 3array ] if first ]
    { nth-unsafe < <= > >= } inlined?
] unit-test

{ } [
    [ [ [ "A" throw ] dip ] [ "B" throw ] if ]
    cleaned-up-tree drop
] unit-test

! Regression from benchmark.nsieve
: chicken-fingers ( i seq -- )
    2dup < [
        2drop
    ] [
        chicken-fingers
    ] if ; inline recursive

: buffalo-wings ( i seq -- )
    2dup < [
        2dup chicken-fingers
        [ 1 + ] dip buffalo-wings
    ] [
        2drop
    ] if ; inline recursive

{ t } [
    [ 2 swap >fixnum buffalo-wings ]
    { <-integer-fixnum +-integer-fixnum } inlined?
] unit-test

! A reduction
: buffalo-sauce ( -- value ) f ;

: steak ( -- )
    buffalo-sauce [ steak ] when ; inline recursive

: ribs ( i seq -- )
    2dup < [
        steak
        [ 1 + ] dip ribs
    ] [
        2drop
    ] if ; inline recursive

{ t } [
    [ 2 swap >fixnum ribs ]
    { <-integer-fixnum +-integer-fixnum } inlined?
] unit-test

{ t } [
    [ hashtable new ] \ new inlined?
] unit-test

{ t } [
    [ { array-capacity } declare 1 fixnum+ ] cleaned-up-tree
    [ { [ #call? ] [ node-input-infos second literal>> 1 = ] } 1&& ] any?
] unit-test

{ } [
    [ { null } declare [ 1 ] [ 2 ] if ]
    build-tree normalize propagate cleanup-tree check-nodes
] unit-test

{ t } [
    [ { array } declare 2 <groups> [ . . ] assoc-each ]
    \ nth-unsafe inlined?
] unit-test

{ t } [
    [ { fixnum fixnum } declare = ]
    \ both-fixnums? inlined?
] unit-test

{ t } [
    [ { integer integer } declare + drop ]
    { + +-integer-integer } inlined?
] unit-test

{ [ ] } [
    [
        20 f <array>
        [ 0 swap nth ] keep
        [ 1 swap nth ] keep
        [ 2 swap nth ] keep
        [ 3 swap nth ] keep
        [ 4 swap nth ] keep
        [ 5 swap nth ] keep
        [ 6 swap nth ] keep
        [ 7 swap nth ] keep
        [ 8 swap nth ] keep
        [ 9 swap nth ] keep
        [ 10 swap nth ] keep
        [ 11 swap nth ] keep
        [ 12 swap nth ] keep
        14 ndrop
    ] cleaned-up-tree nodes>quot
] unit-test

{ t } [
    [ int { } cdecl [ 2 2 + ] alien-callback ]
    { + } inlined?
] unit-test

{ t } [
    [ double { double double } cdecl [ + ] alien-callback ]
    \ + inlined?
] unit-test

{ f } [
    [ double { double double } cdecl [ + ] alien-callback ]
    \ float+ inlined?
] unit-test

{ f } [
    [ char { char char } cdecl [ + ] alien-callback ]
    \ fixnum+fast inlined?
] unit-test

{ t } [
    [ void { } cdecl [ ] alien-callback void { } cdecl alien-indirect ]
    \ >c-ptr inlined?
] unit-test

MIXIN: foo-mix

! cleanup-folding?
: call-node-foldable2 ( -- node )
    T{ #call
       { word foo-mix? }
       { in-d V{ 8815401 } }
       { out-d { 8815405 } }
       { info
         H{
             {
                 8815401
                 T{ value-info-state
                    { class
                      intersection{
                          not{
                              POSTPONE: f
                          }
                          not{ foo-mix }
                      }
                    }
                    { interval
                      full-interval
                    }
                  }
             }
             {
                 8815405
                 T{ value-info-state
                    { class POSTPONE: f }
                    { interval
                      empty-interval
                    }
                    { literal? t }
                  }
             }
         }
       }
    } ;

{ t } [
    call-node-foldable2 cleanup-folding?
] unit-test


! cleanup-folding
: call-node-foldable ( -- node )
    T{ #call
       { word set-slot }
       { in-d V{ 1 2 } }
       { out-d V{ 3 } }
       { info
         H{
             {
                 1
                 T{ value-info-state
                    { class fixnum }
                    { literal 2 }
                    { literal? t }
                 }
             }
             {
                 2
                 T{ value-info-state
                    { class fixnum }
                    { literal 3 }
                    { literal? t }
                 }
             }
             {
                 3
                 T{ value-info-state
                    { class fixnum }
                    { literal 5 }
                    { literal? t }
                 }
             }
         }
       }
    } ;

{ t t } [
    call-node-foldable cleanup-folding
    [ length 2 = ] [ last literal>> 5 = ] bi
] unit-test
