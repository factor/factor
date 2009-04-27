! (c)2009 Joe Groff bsd license
USING: accessors pair-methods classes kernel sequences tools.test ;
IN: pair-methods.tests

TUPLE: thang ;

TUPLE: foom < thang ;
TUPLE: barm < foom ;

TUPLE: zim < thang ;
TUPLE: zang < zim ;

: class-names ( a b prefix -- string )
    [ [ class name>> ] bi@ "-" glue ] dip prepend ;

PAIR-GENERIC: blibble ( a b -- c )

PAIR-M: thang thang blibble
    "vanilla " class-names ;

PAIR-M: foom thang blibble
    "chocolate " class-names ;

PAIR-M: barm thang blibble
    "strawberry " class-names ;

PAIR-M: barm zim blibble
    "coconut " class-names ;

[ "vanilla zang-zim" ] [ zim new zang new blibble ] unit-test

! args automatically swap to match most specific method
[ "chocolate foom-zim" ] [ foom new zim  new blibble ] unit-test
[ "chocolate foom-zim" ] [ zim  new foom new blibble ] unit-test

[ "strawberry barm-barm" ] [ barm new barm new blibble ] unit-test
[ "strawberry barm-foom" ] [ barm new foom new blibble ] unit-test
[ "strawberry barm-foom" ] [ foom new barm new blibble ] unit-test

[ "coconut barm-zang" ] [ zang new barm new blibble ] unit-test
[ "coconut barm-zim" ] [ barm new zim  new blibble ] unit-test

[ 1 2 blibble ] [ no-pair-method? ] must-fail-with
