USING: compiler.cfg.debugger compiler.cfg compiler.cfg.linearization.order
kernel accessors sequences sets tools.test ;
IN: compiler.cfg.linearization.order.tests

V{ } 0 test-bb

V{ } 1 test-bb

V{ } 2 test-bb

0 { 1 1 } edges
1 2 edge

[ t ] [ cfg new 0 get >>entry linearization-order [ id>> ] map all-unique? ] unit-test
