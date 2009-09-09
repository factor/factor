USING: accessors compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.save-contexts namespaces
tools.test ;
IN: compiler.cfg.save-contexts.tests

V{
    T{ ##save-context f 0 1 f }
    T{ ##save-context f 0 1 t }
    T{ ##branch }
} 0 test-bb

0 get combine-in-block

[
    V{
        T{ ##save-context f 0 1 t }
        T{ ##branch }
    }
] [
    0 get instructions>>
] unit-test

V{
    T{ ##add f 1 2 3 }
    T{ ##branch }
} 0 test-bb

0 get combine-in-block

[
    V{
        T{ ##add f 1 2 3 }
        T{ ##branch }
    }
] [
    0 get instructions>>
] unit-test
