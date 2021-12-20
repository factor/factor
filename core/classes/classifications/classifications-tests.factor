USING: classes.algebra classes.classifications classes.classifications.private
combinators.short-circuit compiler.units kernel math namespaces tools.test words
;
IN: classes.classifications.tests

! These are disjoint subsets, with implied test order.  First match always wins.
PREDICATE: 8bit < integer { [ 256 < ] } 1&& ;
PREDICATE: 16bit < integer { [ 8bit? not ] [ 65536 < ] } 1&& ;
PREDICATE: unsigned < integer { [ 8bit? not ] [ 16bit? not ] [ 0 > ] } 1&& ;

GENERIC: bounds ( n -- n )
M: 8bit bounds drop 256 ;
M: 16bit bounds drop 65536 ;
M: unsigned bounds drop 1/0. ;

{ 256 } [ 1 bounds ] unit-test
{ 65536 } [ 256 bounds ] unit-test
{ 1/0. } [ 100000 bounds ] unit-test

{ [ { [ 256 < ] } 1&& ] } [ V{ } [ 256 < ] exclude-negations ] unit-test
{ [ { [ 8bit? not ] [ 65536 < ] } 1&& ] } [ V{ 8bit } [ 65536 < ] exclude-negations ] unit-test

DEFER: foo1
DEFER: foo2
DEFER: foo1?
DEFER: foo2?
{ T{ classification-builder f integer V{ { foo1 [ 1 = ] } { foo2 [ 2 = ] } } } }
[ integer [
      \ foo1 [ 1 = ] define-classified
      \ foo2 [ 2 = ] define-classified
      current-classification get
  ] with-new-classification ] unit-test

{ }
[ [ T{ classification-builder f integer V{ { foo1 [ 1 = ] } { foo2 [ 2 = ] } } }
    finalize-classification
  ] with-compilation-unit ] unit-test

{ t } [ 1 foo1? ] unit-test
{ f } [ 2 foo1? ] unit-test
{ f } [ 1 foo2? ] unit-test
{ t } [ 2 foo2? ] unit-test
{ f } [ 3 foo1? ] unit-test
{ f } [ 3 foo2? ] unit-test

CLASSIFY integer
AS: negative 0 < ;
AS: 0-to-20 20 < ;
AS: 20-to-40 40 < ;
ELSE: above-40

{ HS{ negative 0-to-20 20-to-40 } } [ above-40 "disjoint" word-prop ] unit-test
{ HS{ negative above-40 0-to-20 } } [ 20-to-40 "disjoint" word-prop ] unit-test
{ HS{ 0-to-20 above-40 20-to-40 } } [ negative "disjoint" word-prop ] unit-test

GENERIC: upper ( number -- number )
M: negative upper drop 0 ;
M: 0-to-20 upper drop 20 ;
M: 20-to-40 upper drop 40 ;
M: above-40 upper drop 1/0. ;

PREDICATE: exactly-10 < 0-to-20 10 = ;
M: exactly-10 upper drop 11 ;

{ t } [ 10 exactly-10? ] unit-test
{ t } [ exactly-10 0-to-20 class<= ] unit-test
{ f } [ 0-to-20 exactly-10 class<= ] unit-test

{ 20 } [ 9 upper ] unit-test
{ 11 } [ 10 upper ] unit-test
{ 20 } [ 11 upper ] unit-test
{ 40 } [ 30 upper ] unit-test
{ 1/0. } [ 50 upper ] unit-test

CLASSIFY negative
AS: somewhat-negative -50 > ;
ELSE: very-negative

{ HS{ 0-to-20 above-40 20-to-40 somewhat-negative } } [ very-negative "disjoint" word-prop ] unit-test
{ HS{ 0-to-20 above-40 20-to-40 very-negative } } [ somewhat-negative "disjoint" word-prop ] unit-test

CLASSIFY above-40
AS: below-100 100 < ;
ELSE: very-positive

! Intersection tests
{ f } [ negative 0-to-20 classes-intersect? ] unit-test
{ f } [ very-negative somewhat-negative classes-intersect? ] unit-test
{ f } [ very-positive very-negative classes-intersect? ] unit-test
{ f } [ very-positive 0-to-20 classes-intersect? ] unit-test

{ t } [ very-positive above-40 classes-intersect? ] unit-test
{ t } [ very-positive integer classes-intersect? ] unit-test
