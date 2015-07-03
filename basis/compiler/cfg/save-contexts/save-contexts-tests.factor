USING: accessors compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.save-contexts kernel namespaces tools.test
cpu.x86.assembler.operands cpu.architecture ;
IN: compiler.cfg.save-contexts.tests

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
    T{ ##inc f D 3 }
    T{ ##box f 4 3 "from_signed_4" int-rep
        T{ gc-map { scrub-d B{ 0 0 0 } } { scrub-r B{ } } { gc-roots { } } }
    }
} 0 test-bb

0 get [ insert-save-context ] change-instructions drop

{
    V{
        T{ ##inc f D 3 }
        T{ ##save-context f 5 6 }
        T{ ##box f 4 3 "from_signed_4" int-rep
            T{ gc-map { scrub-d B{ 0 0 0 } } { scrub-r B{ } } { gc-roots { } } }
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
