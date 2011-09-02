! Copyright (C) 2010 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs calendar math math.functions memcached
memcached.private kernel present sequences sorting system
threads tools.test ;

IN: memcached.tests

<PRIVATE

: not-found? ( quot -- )
    [ key-not-found? ] must-fail-with ;

: x ( -- str ) cpu present "-x" append ;
: y ( -- str ) cpu present "-y" append ;
: z ( -- str ) cpu present "-z" append ;

PRIVATE>

! test version
[ t ] [ [ m/version ] with-memcached length 0 > ] unit-test

! test simple set get
[ m/flush ] with-memcached
[ "valuex" x m/set ] with-memcached
[ "valuex" ] [ [ x m/get ] with-memcached ] unit-test

! test flush
[ m/flush ] with-memcached
[ "valuex" x m/set "valuey" y m/set ] with-memcached
[ "valuex" ] [ [ x m/get ] with-memcached ] unit-test
[ "valuey" ] [ [ y m/get ] with-memcached ] unit-test
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ [ y m/get ] with-memcached ] not-found?

! test noop
[ m/noop ] with-memcached

! test delete
[ m/flush ] with-memcached
[ "valuex" x m/set ] with-memcached
[ "valuex" ] [ [ x m/get ] with-memcached ] unit-test
[ x m/delete ] with-memcached
[ [ x m/get ] with-memcached ] not-found?

! test replace
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ [ "ex" x m/replace ] with-memcached ] not-found?
[ "ex" x m/add ] with-memcached
[ "ex" ] [ [ x m/get ] with-memcached ] unit-test
[ "ex2" x m/replace ] with-memcached
[ "ex2" ] [ [ x m/get ] with-memcached ] unit-test

! test incr
[ m/flush ] with-memcached
[ 0 ] [ [ x m/incr ] with-memcached ] unit-test
[ 1 ] [ [ x m/incr ] with-memcached ] unit-test
[ 212 ] [ [ 211 x m/incr-val ] with-memcached ] unit-test
[ 8589934804 ] [ [ 2 33 ^ x m/incr-val ] with-memcached ] unit-test

! test decr
[ m/flush ] with-memcached
[ "5" x m/set ] with-memcached
[ 4 ] [ [ x m/decr ] with-memcached ] unit-test
[ 0 ] [ [ 211 x m/decr-val ] with-memcached ] unit-test

! test timebombed flush
[ m/flush ] with-memcached
[ [ x m/get ] with-memcached ] not-found?
[ "valuex" x m/set ] with-memcached
[ "valuex" ] [ [ x m/get ] with-memcached ] unit-test
[ 2 m/flush-later ] with-memcached
[ "valuex" ] [ [ x m/get ] with-memcached ] unit-test
3 seconds sleep
[ [ x m/get ] with-memcached ] not-found?

! test append
[ m/flush ] with-memcached
[ "some" x m/set ] with-memcached
[ "thing" x m/append ] with-memcached
[ "something" ] [ [ x m/get ] with-memcached ] unit-test

! test prepend
[ m/flush ] with-memcached
[ "some" x m/set ] with-memcached
[ "thing" x m/prepend ] with-memcached
[ "thingsome" ] [ [ x m/get ] with-memcached ] unit-test

! test multi-get
[ m/flush ] with-memcached
[ H{ } ] [ [ x y z 3array m/getseq ] with-memcached ] unit-test
[ "5" x m/set ] with-memcached
[ "valuex" y m/set ] with-memcached
[ { "5" "valuex" } ] [
    [ x y z 3array m/getseq values natural-sort ] with-memcached
] unit-test




