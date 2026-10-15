USING: alien.c-types alien.complex cpu.architecture cpu.ppc.32.linux
compiler.cfg.builder.alien.params generic kernel math namespaces
sequences system tools.test vectors ;
IN: cpu.ppc.32.linux.tests

{ { 9 10 } } [ [ V{ 10 9 8 } clone int-regs set
{ int-rep f t } ppc.32 \ prepare-abi-parameter-group lookup-method execute( rep -- )
int-regs get reverse >array ] with-scope ] unit-test
{ 8 } [ [ V{ } clone int-regs set 4 stack-params set
{ int-rep f t } ppc.32 \ prepare-abi-parameter-group lookup-method execute( rep -- )
stack-params get ] with-scope ] unit-test
{ { 4 5 6 7 } } [ [ V{ 7 6 5 4 } clone int-regs set
{ int-rep f f } ppc.32 \ prepare-abi-parameter-group lookup-method execute( rep -- )
int-regs get reverse >array ] with-scope ] unit-test
{ t } [ complex-float ppc \ flatten-struct-type lookup-method execute( c-type -- reps ) first third ] unit-test
