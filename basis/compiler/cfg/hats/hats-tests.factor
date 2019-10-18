USING: compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers make tools.test ;
IN: compiler.cfg.hats.tests

{
    1 V{ T{ ##local-allot { dst 1 } { size 32 } { align 8 } } }
} [
    reset-vreg-counter [ 32 8 f ^^local-allot ] V{ } make
] unit-test
