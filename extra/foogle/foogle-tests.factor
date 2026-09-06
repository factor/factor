USING: arrays continuations effects foogle help.markup help.syntax
help.topics kernel math sequences tools.test typed words ;
IN: foogle.tests

: untyped ( x -- y ) 1 + ;
: documented ( seq -- n ) length ;
HELP: documented
{ $values { "seq" sequence } { "n" integer } } ;
TYPED: typed-integer ( n: integer -- n': integer ) 1 + ;
HELP: typed-integer
{ $values { "n" float } { "n'" float } } ;
TYPED: typed-float ( x: float -- y: float ) 1.0 + ;
: higher-order ( x quot: ( x -- y ) -- y ) call ; inline
: variable ( ..a quot: ( ..a -- ..b ) -- ..b ) call ; inline
: stopping ( -- * ) "stop" throw ;

{ { typed-float typed-integer untyped } } [
    ( input -- output ) { untyped typed-integer typed-float } foogle-in
] unit-test
{ { typed-integer } } [
    ( n: integer -- n': integer )
    { typed-float untyped typed-integer } foogle-in
] unit-test
{ { typed-float typed-integer } } [
    ( n: number -- n': number )
    { typed-float untyped typed-integer } foogle-in
] unit-test
{ { documented } } [
    ( seq: sequence -- n: integer ) { untyped documented } foogle-in
] unit-test
{ { } } [ ( -- ) { stopping untyped } foogle-in ] unit-test
{ { stopping } } [ ( -- * ) { stopping untyped } foogle-in ] unit-test
{ { higher-order } } [
    ( x quot: ( a -- b ) -- y ) { higher-order variable } foogle-in
] unit-test
{ { } } [
    ( x quot: ( a b -- c ) -- y ) { higher-order } foogle-in
] unit-test
{ { variable } } [
    ( ..x quot: ( ..x -- ..y ) -- ..y ) { variable } foogle-in
] unit-test
{ { } } [ ( -- ) { + } foogle-in ] unit-test
{ { } } [ ( -- ) "unknown-effect" <uninterned-word> 1array foogle-in ] unit-test
{ t } [ ( n: integer -- n': integer ) foogle \ typed-integer swap member? ] unit-test
{ t } [ ( -- ) <foogle-search> valid-article? ] unit-test
{ t } [
    ( seq: sequence -- n: integer ) <foogle-search> article-content
    \ documented swap member?
] unit-test
