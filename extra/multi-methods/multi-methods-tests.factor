IN: temporary
USING: multi-methods tools.test kernel math arrays sequences
prettyprint strings classes hashtables assocs namespaces
debugger continuations ;

[ { 1 2 3 4 5 6 } ] [
    { 6 4 5 1 3 2 } [ <=> ] topological-sort
] unit-test

[ -1 ] [
    { fixnum array } { number sequence } classes<
] unit-test

[ 0 ] [
    { number sequence } { number sequence } classes<
] unit-test

[ 1 ] [
    { object object } { number sequence } classes<
] unit-test

[
    {
        { { object integer } [ 1 ] }
        { { object object } [ 2 ] }
        { { POSTPONE: f POSTPONE: f } [ 3 ] }
    }
] [
    {
        { { integer } [ 1 ] }
        { { } [ 2 ] }
        { { f f } [ 3 ] }
    } congruify-methods
] unit-test

GENERIC: first-test

[ t ] [ \ first-test generic? ] unit-test

MIXIN: thing

TUPLE: paper ;    INSTANCE: paper thing
TUPLE: scissors ; INSTANCE: scissors thing
TUPLE: rock ;     INSTANCE: rock thing

GENERIC: beats?

METHOD: beats? { paper scissors } t ;
METHOD: beats? { scissors rock } t ;
METHOD: beats? { rock paper } t ;
METHOD: beats? { thing thing } f ;

: play ( obj1 obj2 -- ? ) beats? 2nip ;

[ { } 3 play ] must-fail
[ t ] [ error get no-method? ] unit-test
[ ] [ error get error. ] unit-test
[ t ] [ T{ paper } T{ scissors } play ] unit-test
[ f ] [ T{ scissors } T{ paper } play ] unit-test

[ t ] [ { beats? paper scissors } method-spec? ] unit-test
[ ] [ { beats? paper scissors } see ] unit-test

GENERIC: legacy-test

M: integer legacy-test sq ;
M: string legacy-test " hey" append ;

[ 25 ] [ 5 legacy-test ] unit-test
[ "hello hey" ] [ "hello" legacy-test ] unit-test

SYMBOL: some-var

HOOK: hook-test some-var

[ t ] [ \ hook-test hook-generic? ] unit-test

METHOD: hook-test { array array } reverse ;
METHOD: hook-test { array } class ;
METHOD: hook-test { hashtable number } assoc-size ;

{ 1 2 3 } some-var set
[ { f t t } ] [ { t t f } hook-test ] unit-test
[ fixnum ] [ 3 hook-test ] unit-test
5.0 some-var set
[ 0 ] [ H{ } hook-test ] unit-test

MIXIN: busted

TUPLE: busted-1 ;
TUPLE: busted-2 ; INSTANCE: busted-2 busted
TUPLE: busted-3 ;

GENERIC: busted-sort

METHOD: busted-sort { busted-1 busted-2 } ;
METHOD: busted-sort { busted-2 busted-3 } ;
METHOD: busted-sort { busted busted } ;
