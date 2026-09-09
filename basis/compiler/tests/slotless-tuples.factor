USING: kernel tools.test ;
IN: compiler.tests.slotless-tuples

TUPLE: slotless-tuple ;
TUPLE: slotless-child < slotless-tuple ;

: <slotless-tuple> ( -- tuple ) slotless-tuple new ;
: <slotless-child> ( -- tuple ) slotless-child boa ;

! #2671: each call must allocate a distinct instance, including inherited layouts.
{ f } [ <slotless-tuple> <slotless-tuple> eq? ] unit-test
{ f } [ <slotless-child> <slotless-child> eq? ] unit-test
{ t } [ <slotless-tuple> dup eq? ] unit-test
