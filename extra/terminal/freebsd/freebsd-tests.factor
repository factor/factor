USING: accessors alien.c-types classes.struct kernel
terminal.freebsd.private tools.test ;
IN: terminal.freebsd.tests

{ 8 2 } [ winsize heap-size winsize c-type-align ] unit-test
{ 65535 } [ winsize new 65535 >>ws_col ws_col>> ] unit-test

{ 0x40087468 } [ TIOCGWINSZ ] unit-test
