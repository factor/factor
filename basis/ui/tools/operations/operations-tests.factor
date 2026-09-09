USING: accessors kernel math sequences tools.annotations tools.test
tools.walker ui.operations ui.tools.operations words ;
IN: ui.tools.operations.tests

GENERIC: breakpoint-generic ( x -- y )
M: integer breakpoint-generic 1 + ;

: reset-available? ( obj -- ? )
    object-operations [ command>> \ reset = ] any? ;

{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ f } [ 123 reset-available? ] unit-test

{ } [ \ breakpoint-generic breakpoint ] unit-test
{ t } [ \ breakpoint-generic reset-available? ] unit-test
{ t } [ M\ integer breakpoint-generic reset-available? ] unit-test
{ } [ \ breakpoint-generic reset ] unit-test
{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ f } [ M\ integer breakpoint-generic annotated? ] unit-test
{ 4 } [ 3 breakpoint-generic ] unit-test

! A method annotated individually can also be reset through its generic.
{ } [ M\ integer breakpoint-generic breakpoint ] unit-test
{ t } [ \ breakpoint-generic reset-available? ] unit-test
{ } [ \ breakpoint-generic reset ] unit-test
{ f } [ \ breakpoint-generic reset-available? ] unit-test
{ 4 } [ 3 breakpoint-generic ] unit-test
