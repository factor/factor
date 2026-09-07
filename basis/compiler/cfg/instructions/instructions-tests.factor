USING: assocs compiler.cfg.def-use compiler.cfg.hats
compiler.cfg.instructions compiler.cfg.linear-scan.assignment
compiler.cfg.renaming compiler.cfg.representations.preferred
compiler.cfg.representations.rewrite compiler.cfg.ssa.construction
compiler.cfg.ssa.construction.private
compiler.cfg.value-numbering.expressions compiler.units
cpu.architecture definitions kernel sequences tools.test
vocabs.loader words ;
IN: compiler.cfg.instructions.tests

! Model an older image whose generated compiler definitions do not yet
! include an instruction. Reloading only the instruction vocabulary must
! rebuild every generated consumer, including all RENAMING: instances.
{ t t } [
    [
        \ ^^blend-vector forget
        {
            M\ ##blend-vector defs-vregs
            M\ ##blend-vector uses-vregs
            M\ ##blend-vector >expr
            M\ ##blend-vector defs-vreg-reps
            M\ ##blend-vector rename-insn-defs
            M\ ##blend-vector ssa-rename-insn-defs
            M\ ##blend-vector convert-insn-defs
            M\ ##blend-vector assign-insn-defs
        } [ forget ] each
        "compiler.cfg.instructions" reload
    ] with-compilation-unit
    "^^blend-vector" "compiler.cfg.hats" lookup-word word?
    {
        defs-vregs uses-vregs >expr defs-vreg-reps
        rename-insn-defs ssa-rename-insn-defs
        convert-insn-defs assign-insn-defs
    } [ "methods" word-prop ##blend-vector swap key? ] all?
] unit-test

{ { 1 } { 2 3 4 } { int-4-rep } } [
    T{ ##blend-vector
        { dst 1 } { mask 2 } { yes 3 } { no 4 } { rep int-4-rep }
    } [ defs-vregs ] [ uses-vregs ] [ defs-vreg-reps ] tri
] unit-test
