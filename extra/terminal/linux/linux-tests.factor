USING: accessors alien.c-types classes.struct kernel
terminal.linux.private tools.test ;
IN: terminal.linux.tests

{ 8 2 } [ winsize heap-size winsize c-type-align ] unit-test
{ 65535 } [ winsize new 65535 >>ws_col ws_col>> ] unit-test
