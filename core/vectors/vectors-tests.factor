USING: accessors arrays classes continuations kernel math
namespaces random sequences tools.test vectors ;

{ } [ 10 [ [ -1000000 <vector> ] ignore-errors ] times ] unit-test

{ 3 } [ [ t f t ] length ] unit-test
{ 3 } [ V{ t f t } length ] unit-test

[ -3 V{ } nth ] must-fail
[ 3 V{ } nth ] must-fail
[ 3 54.3 nth ] must-fail

[ "hey" [ 1 2 ] set-length ] must-fail
[ "hey" V{ 1 2 } set-length ] must-fail

{ 3 } [ 3 0 <vector> [ set-length ] keep length ] unit-test
{ "yo" } [
    "yo" 4 1 <vector> [ set-nth ] keep 4 swap nth
] unit-test

[ 1 V{ } nth ] must-fail
[ -1 V{ } set-length ] must-fail
{ V{ } } [ [ ] >vector ] unit-test
{ V{ 1 2 } } [ [ 1 2 ] >vector ] unit-test

{ t } [
    100 [ 100 random ] V{ } replicate-as
    dup >array >vector =
] unit-test

{ f } [ V{ } V{ 1 2 3 } = ] unit-test
{ f } [ V{ 1 2 } V{ 1 2 3 } = ] unit-test
{ f } [ [ 1 2 ] V{ 1 2 3 } = ] unit-test
{ f } [ V{ 1 2 } [ 1 2 3 ] = ] unit-test

{ { 1 4 9 16 } }
[
    [ 1 2 3 4 ]
    >vector [ dup * ] map >array
] unit-test

{ t } [ V{ } hashcode V{ } hashcode = ] unit-test
{ t } [ V{ 1 2 3 } hashcode V{ 1 2 3 } hashcode = ] unit-test
{ t } [ V{ 1 V{ 2 } 3 } hashcode V{ 1 V{ 2 } 3 } hashcode = ] unit-test
{ t } [ V{ } hashcode V{ } hashcode = ] unit-test

{ V{ 1 2 3 } V{ 1 2 3 4 5 6 } }
[ V{ 1 2 3 } dup V{ 4 5 6 } append ] unit-test

{ V{ 1 2 3 4 } } [ [ V{ 1 } [ 2 ] V{ 3 4 } ] concat ] unit-test

{ V{ } } [ V{ } 0 tail ] unit-test
{ V{ } } [ V{ 1 2 } 2 tail ] unit-test
{ V{ 3 4 } } [ V{ 1 2 3 4 } 2 tail ] unit-test

{ V{ 3 } } [ V{ 1 2 3 } 1 tail* ] unit-test

0 <vector> "funny-stack" set

{ } [ V{ 1 5 } "funny-stack" get push ] unit-test
{ } [ V{ 2 3 } "funny-stack" get push ] unit-test
{ V{ 2 3 } } [ "funny-stack" get pop ] unit-test
{ V{ 1 5 } } [ "funny-stack" get last ] unit-test
{ V{ 1 5 } } [ "funny-stack" get pop ] unit-test
[ "funny-stack" get pop ] must-fail
[ "funny-stack" get pop ] must-fail
{ } [ "funky" "funny-stack" get push ] unit-test
{ "funky" } [ "funny-stack" get pop ] unit-test

{ t } [
    V{ 1 2 3 4 } dup underlying>> length
    [ clone underlying>> length ] dip
    =
] unit-test

{ f } [
    V{ 1 2 3 4 } dup clone
    [ underlying>> ] bi@ eq?
] unit-test

{ 0 } [
    10 <vector> "x" [
        "x" get clone length
    ] with-variable
] unit-test

{ f } [ 5 V{ } index ] unit-test
{ 4 } [ 5 V{ 1 2 3 4 5 } index ] unit-test

{ t } [
    100 <iota> >array dup >vector <reversed> >array [ reverse ] dip =
] unit-test

{ fixnum } [ 1 >bignum V{ } new-sequence length class-of ] unit-test

{ fixnum } [ 1 >bignum <iota> [ ] V{ } map-as length class-of ] unit-test

{ V{ "lulz" } } [ "lulz" 1vector ] unit-test

{ V{ "foo" } } [ "foo" V{ } ?push ] unit-test
{ V{ 1 "foo" } } [ "foo" V{ 1 } ?push ] unit-test
{ V{ "foo" } } [ "foo" f ?push ] unit-test
