USING: arrays combinators literals accessors alien.c-types assocs compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params cpu.architecture cpu.m88k.abi
cpu.m88k.assembler.registers kernel namespaces sequences system tools.test vectors ;
IN: cpu.m88k.abi.tests
: abi32 ( quot -- ) [ m88k.32 \ cpu ] dip with-variable ; inline
{ { 2 3 4 5 6 7 8 9 } } [ [ f param-regs int-regs of [ n>> ] map ] abi32 ] unit-test
{ { 2 3 } } [ [ return-regs int-regs of [ n>> ] map ] abi32 ] unit-test
{ 12 } [ [ struct-return-register n>> ] abi32 ] unit-test
{ { 8 9 } } [ [
    ${ R9 R8 R7 } >vector int-regs set 0 stack-params set
    { int-rep f f 4 0 8 } prepare-abi-parameter-group
    int-regs get reverse [ n>> ] map >array
] [ m88k.32 \ cpu set ] prepose with-scope ] unit-test
{ { int-rep int-rep } } [ [
    0 int-reg-reps set 0 float-reg-reps set
    double flatten-scalar-parameter [ first ] map
] [ m88k.32 \ cpu set ] prepose with-scope ] unit-test
{ { 9 } t t } [ [
    ${ R9 } >vector int-regs set 0 stack-params set
    { int-rep f f 4 0 8 } clone dup prepare-abi-parameter-group second
    { int-rep f f 4 0 1 } clone dup prepare-abi-parameter-group second
    int-regs get [ n>> ] map >array -rot
] [ m88k.32 \ cpu set ] prepose with-scope ] unit-test
