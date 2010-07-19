USING: accessors compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.save-contexts kernel namespaces tools.test
cpu.x86.assembler.operands cpu.architecture ;
IN: compiler.cfg.save-contexts.tests

0 vreg-counter set-global
H{ } clone representations set

V{
    T{ ##unary-float-function f 2 3 "sqrt" }
    T{ ##branch }
} 0 test-bb

0 get insert-save-context

[
    V{
        T{ ##save-context f 1 2 }
        T{ ##unary-float-function f 2 3 "sqrt" }
        T{ ##branch }
    }
] [
    0 get instructions>>
] unit-test

V{
    T{ ##add f 1 2 3 }
    T{ ##branch }
} 0 test-bb

0 get insert-save-context

[
    V{
        T{ ##add f 1 2 3 }
        T{ ##branch }
    }
] [
    0 get instructions>>
] unit-test

4 vreg-counter set-global

V{
    T{ ##inc-d f 3 }
    T{ ##box f 4 3 "from_signed_4" int-rep
        T{ gc-map { scrub-d B{ 0 0 0 } } { scrub-r B{ } } { gc-roots { } } }
    }
} 0 test-bb

0 get insert-save-context

[
    V{
        T{ ##inc-d f 3 }
        T{ ##save-context f 5 6 }
        T{ ##box f 4 3 "from_signed_4" int-rep
            T{ gc-map { scrub-d B{ 0 0 0 } } { scrub-r B{ } } { gc-roots { } } }
        }
    }
] [
    0 get instructions>>
] unit-test

V{
    T{ ##phi }
    T{ ##add }
} 0 test-bb

0 get insert-save-context

[
    V{
        T{ ##phi }
        T{ ##save-context f 7 8 }
        T{ ##add }
    }
] [
    0 get instructions>>
] unit-test
