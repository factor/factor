USING: tools.test cpu.architecture
compiler.cfg.registers compiler.cfg.instructions
compiler.cfg.representations.preferred ;
IN: compiler.cfg.representations

[ { double-float-rep double-float-rep } ] [
    T{ ##add-float
       { dst V double-float-rep 5 }
       { src1 V double-float-rep 3 }
       { src2 V double-float-rep 4 }
    } uses-vreg-reps
] unit-test

[ double-float-rep ] [
    T{ ##alien-double
       { dst V double-float-rep 5 }
       { src V int-rep 3 }
    } defs-vreg-rep
] unit-test