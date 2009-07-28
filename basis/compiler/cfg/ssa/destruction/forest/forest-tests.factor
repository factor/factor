USING: accessors compiler.cfg compiler.cfg.ssa.destruction.forest
compiler.cfg.debugger compiler.cfg.dominance compiler.cfg.instructions
compiler.cfg.predecessors compiler.cfg.registers compiler.cfg.def-use
cpu.architecture kernel namespaces sequences tools.test vectors sorting
math.order ;
IN: compiler.cfg.ssa.destruction.forest.tests

V{ T{ ##peek f V int-regs 0 D 0 } } clone 0 test-bb
V{ T{ ##peek f V int-regs 1 D 0 } } clone 1 test-bb
V{ T{ ##peek f V int-regs 2 D 0 } } clone 2 test-bb
V{ T{ ##peek f V int-regs 3 D 0 } } clone 3 test-bb
V{ T{ ##peek f V int-regs 4 D 0 } } clone 4 test-bb
V{ T{ ##peek f V int-regs 5 D 0 } } clone 5 test-bb
V{ T{ ##peek f V int-regs 6 D 0 } } clone 6 test-bb

0 get 1 get 2 get V{ } 2sequence >>successors drop
2 get 3 get 4 get V{ } 2sequence >>successors drop
3 get 5 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop
1 get 6 get 1vector >>successors drop
5 get 6 get 1vector >>successors drop

: clean-up-forest ( forest -- forest' )
    [ [ vreg>> n>> ] compare ] sort
    [
        [ clean-up-forest ] change-children
        [ number>> ] change-bb
    ] V{ } map-as ;

: test-dom-forest ( vregs -- forest )
    cfg new 0 get >>entry
    compute-predecessors
    dup compute-dominance
    compute-def-use
    compute-dom-forest
    clean-up-forest ;

[ V{ } ] [ { } test-dom-forest ] unit-test

[ V{ T{ dom-forest-node f V int-regs 0 0 V{ } } } ]
[ { V int-regs 0 } test-dom-forest ]
unit-test

[
    V{
        T{ dom-forest-node
           f
           V int-regs 0
           0
           V{ T{ dom-forest-node f V int-regs 1 1 V{ } } }
        }
    }
]
[ { V int-regs 0 V int-regs 1 } test-dom-forest ]
unit-test

[
    V{
        T{ dom-forest-node
           f
           V int-regs 1
           1
           V{ }
        }
        T{ dom-forest-node
           f
           V int-regs 2
           2
           V{
               T{ dom-forest-node f V int-regs 3 3 V{ } }
               T{ dom-forest-node f V int-regs 4 4 V{ } }
               T{ dom-forest-node f V int-regs 5 5 V{ } }
           }
        }
        T{ dom-forest-node
           f
           V int-regs 6
           6
           V{ }
        }
    }
]
[
    { V int-regs 1 V int-regs 6 V int-regs 2 V int-regs 3 V int-regs 4 V int-regs 5 }
    test-dom-forest
] unit-test