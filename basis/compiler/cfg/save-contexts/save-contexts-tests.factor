USING: accessors compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.save-contexts compiler.test cpu.architecture kernel
namespaces tools.test ;
IN: compiler.cfg.save-contexts.tests

! insns-needs-save-context?
{ f f t } [
    {
        T{ ##call-gc }
    } insns-needs-save-context?
    {
        T{ ##add f 1 2 3 }
        T{ ##branch }
    } insns-needs-save-context?
    { T{ ##alien-invoke } } insns-needs-save-context?
] unit-test

H{ } clone representations set

V{
    T{ ##add f 1 2 3 }
    T{ ##branch }
} 0 test-bb

0 get [ insert-save-context ] change-instructions drop

{
    V{
        T{ ##add f 1 2 3 }
        T{ ##branch }
    }
} [
    0 get instructions>>
] unit-test

4 vreg-counter set-global

V{
    T{ ##inc f D: 3 }
    T{ ##box f 4 3 "from_signed_4" int-rep
       T{ gc-map { gc-roots { } } }
    }
} 0 test-bb

0 get [ insert-save-context ] change-instructions drop

{
    V{
        T{ ##inc f D: 3 }
        T{ ##save-context f 5 6 }
        T{ ##box f 4 3 "from_signed_4" int-rep
            T{ gc-map { gc-roots { } } }
        }
    }
} [
    0 get instructions>>
] unit-test

V{
    T{ ##phi }
    T{ ##box }
} 0 test-bb

0 get [ insert-save-context ] change-instructions drop

{
    V{
        T{ ##phi }
        T{ ##save-context f 7 8 }
        T{ ##box }
    }
} [
    0 get instructions>>
] unit-test

{ 3 } [
    V{
        T{ ##phi }
        T{ ##phi }
        T{ ##phi }
        T{ insn }
    } save-context-offset
] unit-test
