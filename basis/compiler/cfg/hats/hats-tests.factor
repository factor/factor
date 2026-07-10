USING: compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers effects make tools.test words ;
IN: compiler.cfg.hats.tests

{
    1 V{ T{ ##local-allot { dst 1 } { size 32 } { align 8 } } }
} [
    reset-vreg-counter [ 32 8 f ^^local-allot ] V{ } make
] unit-test

! Generated hats must be refreshed when an instruction gains a literal slot.
{ ( src rep unsigned? -- vreg ) }
[ \ ^^float>integer-vector stack-effect ] unit-test
