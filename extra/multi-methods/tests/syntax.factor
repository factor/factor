USING: multi-methods tools.test math sequences namespaces system
kernel strings definitions prettyprint debugger arrays
hashtables continuations classes assocs accessors see ;
RENAME: GENERIC: multi-methods => multi-methods:GENERIC:
IN: multi-methods.tests

multi-methods:GENERIC: first-test ( -- )

{ t } [ \ first-test generic? ] unit-test

MIXIN: thing

SINGLETON: paper    INSTANCE: paper thing
SINGLETON: scissors INSTANCE: scissors thing
SINGLETON: rock     INSTANCE: rock thing

multi-methods:GENERIC: beats? ( obj1 obj2 -- ? )

METHOD: beats? { paper scissors } 2drop t ;
METHOD: beats? { scissors rock } 2drop t ;
METHOD: beats? { rock paper } 2drop t ;
METHOD: beats? { thing thing } 2drop f ;

: play ( obj1 obj2 -- ? ) beats? ;

[ { } 3 play ] must-fail
{ t } [ error get no-method? ] unit-test
{ } [ error get error. ] unit-test
{ { { } 3 } } [ error get arguments>> ] unit-test
{ t } [ paper scissors play ] unit-test
{ f } [ scissors paper play ] unit-test

{ t } [ { beats? paper scissors } method-spec? ] unit-test
{ } [ { beats? paper scissors } see ] unit-test

SYMBOL: some-var

multi-methods:GENERIC: hook-test ( obj -- obj )

METHOD: hook-test { array { some-var array } } reverse ;
METHOD: hook-test { { some-var array } } class-of ;
METHOD: hook-test { hashtable { some-var number } } assoc-size ;

{ 1 2 3 } some-var set
{ { f t t } } [ { t t f } hook-test ] unit-test
{ fixnum } [ 3 hook-test ] unit-test
5.0 some-var set
{ 0 } [ H{ } hook-test ] unit-test

"error" some-var set
[ H{ } hook-test ] must-fail
{ t } [ error get no-method? ] unit-test
{ { H{ } "error" } } [ error get arguments>> ] unit-test

MIXIN: busted

TUPLE: busted-1 ;
TUPLE: busted-2 ; INSTANCE: busted-2 busted
TUPLE: busted-3 ;

multi-methods:GENERIC: busted-sort ( obj1 obj2 -- obj1 obj2 )

METHOD: busted-sort { busted-1 busted-2 } ;
METHOD: busted-sort { busted-2 busted-3 } ;
METHOD: busted-sort { busted busted } ;
