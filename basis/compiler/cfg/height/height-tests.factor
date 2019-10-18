USING: compiler.cfg.height compiler.cfg.instructions
compiler.cfg.registers tools.test ;
IN: compiler.cfg.height.tests

[
    V{
        T{ ##inc-r f -1 f }
        T{ ##inc-d f 4 f }
        T{ ##peek f 0 D 4 f }
        T{ ##peek f 1 D 0 f }
        T{ ##replace f 0 R -1 f }
        T{ ##replace f 1 R 0 f }
        T{ ##peek f 2 D 0 f }
    }
] [
    V{
        T{ ##peek f 0 D 0 }
        T{ ##inc-d f 3 }
        T{ ##peek f 1 D -1 }
        T{ ##replace f 0 R 0 }
        T{ ##inc-r f -1 }
        T{ ##replace f 1 R 0 }
        T{ ##inc-d f 1 }
        T{ ##peek f 2 D 0 }
    } height-step
] unit-test
