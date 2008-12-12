USING: io.unix.multiplexers.run-loop tools.test
destructors ;
IN: io.unix.multiplexers.run-loop.tests

[ ] [ <run-loop-mx> dispose ] unit-test
