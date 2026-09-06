USING: eval kernel math math.functions tools.test words ;
IN: compiler.tests.redefine27

: custom-source ( x -- y ) sqrt ;
<<
\ custom-source [ drop [ drop 2 ] ] "custom-inlining" set-word-prop
>>
: custom-caller ( x -- y ) custom-source ;

{ 2 } [ 2 custom-caller ] unit-test

{ } [
    \ custom-source [ drop [ drop 3 ] ] "custom-inlining" set-word-prop
    "IN: compiler.tests.redefine27 USE: math
    : custom-source ( x -- y ) 2^ ;" eval( -- )
] unit-test
{ 3 } [ 2 custom-caller ] unit-test

{ } [
    \ custom-source "custom-inlining" remove-word-prop
    "IN: compiler.tests.redefine27 USE: math
    : custom-source ( x -- y ) 4 + ;" eval( -- )
] unit-test
{ 6 } [ 2 custom-caller ] unit-test

! A hook declining to inline still depends on its owning definition.
: fallback-source ( x -- y ) 1 + ;
<< \ fallback-source [ drop f ] "custom-inlining" set-word-prop >>
: fallback-caller ( x -- y ) fallback-source ;
{ 3 } [ 2 fallback-caller ] unit-test
{ } [
    \ fallback-source [ drop [ drop 7 ] ] "custom-inlining" set-word-prop
    "IN: compiler.tests.redefine27 USE: math
    : fallback-source ( x -- y ) 2 + ;" eval( -- )
] unit-test
{ 7 } [ 2 fallback-caller ] unit-test
