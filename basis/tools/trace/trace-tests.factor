IN: tools.trace.tests
USING: tools.trace tools.test tools.continuations kernel math combinators
sequences ;

[ { 3 2 1 } ] [ { 1 2 3 } [ reverse ] trace ] unit-test

GENERIC: method-breakpoint-test ( x -- y )

TUPLE: method-breakpoint-tuple ;

M: method-breakpoint-tuple method-breakpoint-test break drop 1 2 + ;

\ method-breakpoint-test don't-step-into

[ 3 ]
[ [ T{ method-breakpoint-tuple } method-breakpoint-test ] trace ] unit-test

: case-breakpoint-test ( -- x )
    5 { [ break 1 + ] } case ;

\ case-breakpoint-test don't-step-into

[ 6 ] [ [ case-breakpoint-test ] trace ] unit-test

: call(-breakpoint-test ( -- x )
    [ break 1 ] call( -- x ) 2 + ;

\ call(-breakpoint-test don't-step-into

[ 3 ] [ [ call(-breakpoint-test ] trace ] unit-test
