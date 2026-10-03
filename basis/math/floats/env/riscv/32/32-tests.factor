USING: kernel math.floats.env math.floats.env.private
math.floats.env.riscv.32 tools.test ;
IN: math.floats.env.riscv.32.tests

{ f f } [ fp-traps-supported? denormal-flush-supported? ] unit-test
{ { } } [ fp-traps ] unit-test
{ +denormal-keep+ } [ denormal-mode ] unit-test
[ { +fp-zero-divide+ } set-fp-traps ] [ unsupported-riscv-fp-traps? ] must-fail-with
[ +denormal-flush+ set-denormal-mode ] [ unsupported-riscv-denormal-mode? ] must-fail-with
