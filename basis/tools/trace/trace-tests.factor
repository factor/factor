IN: tools.trace.tests
USING: combinators kernel math sequences tools.continuations
tools.test tools.trace tools.trace.private ;

{ { 3 2 1 } } [ { 1 2 3 } [ reverse ] trace ] unit-test

GENERIC: method-breakpoint-test ( x -- y )

TUPLE: method-breakpoint-tuple ;

M: method-breakpoint-tuple method-breakpoint-test break drop 1 2 + ;

\ method-breakpoint-test don't-step-into

{ 3 }
[ [ T{ method-breakpoint-tuple } method-breakpoint-test ] trace ] unit-test

: case-breakpoint-test ( -- x )
    5 { [ break 1 + ] } case ;

\ case-breakpoint-test don't-step-into

{ 6 } [ [ case-breakpoint-test ] trace ] unit-test

: call-op-para-breakpoint-test ( -- x )
    [ break 1 ] call( -- x ) 2 + ;

\ call-op-para-breakpoint-test don't-step-into

{ 3 } [ [ call-op-para-breakpoint-test ] trace ] unit-test

{ f t t } [
    \ + into?
    \ dip into?
    \ sq into?
] unit-test
