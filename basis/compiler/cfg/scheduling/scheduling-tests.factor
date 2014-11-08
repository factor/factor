USING: accessors compiler.cfg compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.scheduling compiler.cfg.utilities
vocabs.loader namespaces tools.test arrays kernel random sequences sets words ;
IN: compiler.cfg.scheduling.tests

! Test split-insns
{
    {
        V{ }
        V{ }
        V{ T{ ##test-branch } }
    }
} [ V{ T{ ##test-branch } } split-insns ] unit-test

{
    {
        V{ T{ ##inc-d } T{ ##inc-r } T{ ##callback-inputs } }
        V{ T{ ##add } T{ ##sub } T{ ##mul } }
        V{ T{ ##test-branch } }
    }
} [
    V{
        T{ ##inc-d }
        T{ ##inc-r }
        T{ ##callback-inputs }
        T{ ##add }
        T{ ##sub }
        T{ ##mul }
        T{ ##test-branch }
    } split-insns
] unit-test

[
    {
        V{ }
        V{ T{ ##add } T{ ##sub } T{ ##mul } }
        V{ T{ ##dispatch } }
    }
] [
    V{
        T{ ##add }
        T{ ##sub }
        T{ ##mul }
        T{ ##dispatch }
    } split-insns
] unit-test

! Instructions gets numbered as a side-effect
{ t } [
    V{
        T{ ##inc-r }
        T{ ##inc-d }
        T{ ##load-tagged }
        T{ ##allot }
        T{ ##set-slot-imm }
    } insns>cfg schedule-instructions
    linearization-order [ instructions>> ] map concat [ insn#>> ] all?
] unit-test

: test-1187 ( -- insns )
    V{
        ##inc-r
        ##inc-d
        ##peek
        ##peek
        ##load-tagged
        ##allot
        ##set-slot-imm
        ##load-reference
        ##allot
        ##set-slot-imm
        ##set-slot-imm
        ##set-slot-imm
        ##replace-imm
        ##replace
        ##replace
        ##replace
        ##replace
        ##replace-imm
        ##replace
        ##branch
    } [ new ] map ;

{
    {
        V{ T{ ##inc-r } T{ ##inc-d } }
        V{
            T{ ##peek }
            T{ ##peek }
            T{ ##load-tagged }
            T{ ##allot }
            T{ ##set-slot-imm }
            T{ ##load-reference }
            T{ ##allot }
            T{ ##set-slot-imm }
            T{ ##set-slot-imm }
            T{ ##set-slot-imm }
            T{ ##replace-imm }
            T{ ##replace }
            T{ ##replace }
            T{ ##replace }
            T{ ##replace }
            T{ ##replace-imm }
            T{ ##replace }
        }
        V{ T{ ##branch } }
    }
} [ test-1187 split-insns ] unit-test

! You should get the exact same instruction order each time.
{ 1 } [
    10 [ test-1187 split-insns 1 swap nth ] replicate members length
] unit-test
