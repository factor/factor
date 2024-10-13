USING: locals.lazy math math.functions tools.test ;

IN: locals.lazy.tests

<<
EMIT: calc-c ( a b -- c ) a b sqrt * ;
EMIT: calc-d ( a b -- d ) a sqrt b + ;
>>

:: do-things ( a b -- c d )
    calc-c calc-d ;

{ 1.4142135623730951 3.0 } [ 1 2 do-things ] unit-test

