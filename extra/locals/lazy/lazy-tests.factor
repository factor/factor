USING: locals.lazy math math.functions sequences tools.test ;

IN: locals.lazy.tests

<<
EMIT: calc-c ( a b -- c ) a b sqrt * ;
EMIT: calc-d ( a b -- d ) a sqrt b + ;
>>

:: do-things ( a b -- c d ) calc-c calc-d ;

{ 1.4142135623730951 3.0 } [ 1 2 do-things ] unit-test

<<
EMIT: nested ( a -- b ) a sq :> b b ;
>>

:: do-nested ( a -- b ) nested ;

{ 9 } [ 3 do-nested ] unit-test

<<
EMIT: binding ( a -- b ) a sq :> b! b 10 * b! b ;
>>

:: do-binding ( a -- b ) binding ;

{ 90 } [ 3 do-binding ] unit-test

<<
EMIT: mutable ( a! b -- c ) a sq a! a b * ;
>>

:: do-mutable ( a! b -- c ) mutable ;

{ 18 } [ 3 2 do-mutable ] unit-test

<<
EMIT*: star ( x y -- z ) nth ;
>>

:: do-star ( x y -- z ) star z ;

{ 20 } [ 1 { 10 20 30 } do-star ] unit-test
