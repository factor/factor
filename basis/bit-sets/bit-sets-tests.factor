USING: bit-arrays bit-sets kernel sets tools.test ;

{ T{ bit-set f ?{ t f t f t f } } } [
    T{ bit-set f ?{ t f f f t f } }
    T{ bit-set f ?{ f f t f t f } } union
] unit-test

{ T{ bit-set f ?{ f f f f t f } } } [
    T{ bit-set f ?{ t f f f t f } }
    T{ bit-set f ?{ f f t f t f } } intersect
] unit-test

{ f } [ T{ bit-set f ?{ t f f f t f } } null? ] unit-test
{ t } [ T{ bit-set f ?{ f f f f f f } } null? ] unit-test

{ T{ bit-set f ?{ t f t f f f } } } [
    T{ bit-set f ?{ t t t f f f } }
    T{ bit-set f ?{ f t f f t t } } diff
] unit-test

{ f } [
    T{ bit-set f ?{ t t t f f f } }
    T{ bit-set f ?{ f t f f t t } } subset?
] unit-test

{ t } [
    T{ bit-set f ?{ t t t f f f } }
    T{ bit-set f ?{ f t f f f f } } subset?
] unit-test

{ t } [
    { 0 1 2 }
    T{ bit-set f ?{ f t f f f f } } subset?
] unit-test

{ f } [
    T{ bit-set f ?{ f t f f f f } }
    T{ bit-set f ?{ t t t f f f } } subset?
] unit-test

{ f } [
    { 1 }
    T{ bit-set f ?{ t t t f f f } } subset?
] unit-test

{ V{ 0 2 5 } } [ T{ bit-set f ?{ t f t f f t } } members ] unit-test

{ t V{ 1 2 3 } } [
    { 1 2 } 5 <bit-set> set-like
    [ bit-set? ] keep
    3 over adjoin
    members
] unit-test

{ V{ 0 1 2 5 } } [ T{ bit-set f ?{ t f t f f t } } clone [ 1 swap adjoin ] keep members ] unit-test
[ T{ bit-set f ?{ t f t f f t } } clone [ 9 swap adjoin ] keep members ] must-fail
[ T{ bit-set f ?{ t f t f f t } } clone [ "foo" swap adjoin ] keep members ] must-fail

{ V{ 2 5 } } [ T{ bit-set f ?{ t f t f f t } } clone [ 0 swap delete ] keep members ] unit-test
{ V{ 0 2 5 } } [ T{ bit-set f ?{ t f t f f t } } clone [ 1 swap delete ] keep members ] unit-test
{ V{ 0 2 5 } } [ T{ bit-set f ?{ t f t f f t } } clone [ 9 swap delete ] keep members ] unit-test
{ V{ 0 2 5 } } [ T{ bit-set f ?{ t f t f f t } } clone [ "foo" swap delete ] keep members ] unit-test

{ T{ bit-set f ?{ f } } T{ bit-set f ?{ t } } }
[ 1 <bit-set> dup clone 0 over adjoin ] unit-test

{ 0 } [ T{ bit-set f ?{ } } cardinality ] unit-test
{ 0 } [ T{ bit-set f ?{ f f f f } } cardinality ] unit-test
{ 1 } [ T{ bit-set f ?{ f t f f } } cardinality ] unit-test
{ 2 } [ T{ bit-set f ?{ f t f t } } cardinality ] unit-test
