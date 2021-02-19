USING: assocs classes.dispatch.order classes.dispatch.syntax kernel tools.test
classes.dispatch ;
IN: classes.dispatch.order.tests

CONSTANT: test-lookup { { 1 D{ tuple object } } { 2 D{ object tuple } } { 3 D{ tuple tuple } } }

{ { { object V{ 2 } } { tuple V{ 1 3 } } } }
[ { 1 2 3 } [ test-lookup at 0 swap nth-dispatch-class ] sort-dispatch ] unit-test
