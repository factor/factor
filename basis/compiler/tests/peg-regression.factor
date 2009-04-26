! Calling the compiler at parse time and having it compile
! generic words defined in the current compilation unit would
! fail. This is a regression from the 'remake-generic'
! optimization, which would batch generic word updates at the
! end of a compilation unit.

USING: kernel accessors peg.ebnf ;
IN: compiler.tests.peg-regression

TUPLE: pipeline-expr background ;

GENERIC: blah ( a -- b )

M: pipeline-expr blah ;

: ast>pipeline-expr ( -- obj )
    pipeline-expr new blah ;

EBNF: expr
pipeline = "hello" => [[ ast>pipeline-expr ]]
;EBNF

USE: tools.test

[ t ] [ \ expr optimized>> ] unit-test
[ t ] [ \ ast>pipeline-expr optimized>> ] unit-test
