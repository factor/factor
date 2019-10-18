! Copyright 2007, 2008 Ryan Murphy, Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: arrays kernel math namespaces tools.test
heaps heaps.private math.parser random assocs sequences sorting
accessors math.order locals ;
IN: heaps.tests

[ <min-heap> heap-pop ] must-fail
[ <max-heap> heap-pop ] must-fail

{ t } [ <min-heap> heap-empty? ] unit-test
{ f } [ <min-heap> 1 t pick heap-push heap-empty? ] unit-test
{ t } [ <max-heap> heap-empty? ] unit-test
{ f } [ <max-heap> 1 t pick heap-push heap-empty? ] unit-test

! Binary Min Heap
{ 1 2 3 4 5 6 } [ 0 left 0 right 1 left 1 right 2 left 2 right ] unit-test
{ t } [ t 5 f <entry> t 3 f <entry> T{ min-heap } heap-compare ] unit-test
{ f } [ t 5 f <entry> t 3 f <entry> T{ max-heap } heap-compare ] unit-test

{ t 2 } [ <min-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push heap-pop ] unit-test

{ t 1 } [ <min-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push t 1 pick heap-push heap-pop ] unit-test

{ t 400 } [ <max-heap> t 300 pick heap-push t 200 pick heap-push t 400 pick heap-push t 3 pick heap-push t 2 pick heap-push t 1 pick heap-push heap-pop ] unit-test

{ 0 } [ <max-heap> heap-size ] unit-test
{ 1 } [ <max-heap> t 1 pick heap-push heap-size ] unit-test

: heap-sort ( alist heap -- keys )
    [ heap-push-all ] keep heap-pop-all ;

: random-alist ( n -- alist )
    <iota> [
        drop 32 random-bits dup number>string
    ] H{ } map>assoc >alist ;

:: test-heap-sort ( n heap reverse? -- ? )
    n random-alist
    [ sort-keys reverse? [ reverse ] when ] keep
    heap heap-sort = ;

: test-minheap-sort ( n -- ? )
    <min-heap> f test-heap-sort ;

: test-maxheap-sort ( n -- ? )
    <max-heap> t test-heap-sort ;

14 [
    [ t ] swap [ 2^ <min-heap> f test-heap-sort ] curry unit-test
] each-integer

14 [
    [ t ] swap [ 2^ <max-heap> t test-heap-sort ] curry unit-test
] each-integer

: test-entry-indices ( n -- ? )
    random-alist
    <min-heap> [ heap-push-all ] keep
    data>> dup length <iota> swap [ index>> ] map sequence= ;

14 [
    [ t ] swap [ 2^ test-entry-indices ] curry unit-test
] each-integer

: sort-entries ( entries -- entries' )
    [ key>> ] sort-with ;

: delete-test ( n -- obj1 obj2 )
    [
        random-alist
        <min-heap> [ heap-push-all ] keep
        dup data>> clone swap
    ] keep 3 /i [ 2dup [ delete-random ] dip heap-delete ] times
    data>>
    [ [ key>> ] map ] bi@
    [ natural-sort ] bi@ ;

11 [
    [ t ] swap [ 2^ delete-test sequence= ] curry unit-test
] each-integer
