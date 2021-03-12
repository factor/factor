USING: accessors combinators.short-circuit kernel math
tools.test ;
IN: combinators.short-circuit.tests

{ 3 } [ { [ 1 ] [ 2 ] [ 3 ] } 0&& ] unit-test
{ 5 } [ 3 { [ 0 > ] [ odd? ] [ 2 + ] } 1&& ] unit-test
{ 30 } [ 10 20 { [ + 0 > ] [ - even? ] [ + ] } 2&& ] unit-test

{ f } [ { [ 1 ] [ f ] [ 3 ] } 0&& ] unit-test
{ f } [ 3 { [ 0 > ] [ even? ] [ 2 + ] } 1&& ] unit-test
{ f } [ 10 20 { [ + 0 > ] [ - odd? ] [ + ] } 2&& ] unit-test

{ "factor" } [ { [ 10 0 < ] [ f ] [ "factor" ] } 0|| ] unit-test
{ 11 } [ 10 { [ odd? ] [ 100 > ] [ 1 + ] } 1|| ] unit-test
{ 30 } [ 10 20 { [ + odd? ] [ + 100 > ] [ + ] } 2|| ] unit-test
{ f } [ { [ 10 0 < ] [ f ] [ 0 1 = ] } 0|| ] unit-test

: compiled-&& ( a -- ? ) { [ 0 > ] [ even? ] [ 2 + ] } 1&& ;

{ f } [ 3 compiled-&& ] unit-test
{ 4 } [ 2 compiled-&& ] unit-test

: compiled-|| ( a b -- ? ) { [ + odd? ] [ + 100 > ] [ + ] } 2|| ;

{ 30 } [ 10 20 compiled-|| ] unit-test
{ 2 } [ 1 1 compiled-|| ] unit-test

! && and || should be row-polymorphic both when compiled and when interpreted

: row-&& ( -- ? )
    f t { [ drop dup ] } 1&& nip ;

{ f } [ row-&& ] unit-test
{ f } [ \ row-&& def>> call ] unit-test

: row-|| ( -- ? )
    f t { [ drop dup ] } 1|| nip ;

{ f } [ row-|| ] unit-test
{ f } [ \ row-|| def>> call ] unit-test
