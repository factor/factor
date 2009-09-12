USING: accessors compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.save-contexts kernel namespaces tools.test ;
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
        T{ ##save-context f 1 2 f }
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
