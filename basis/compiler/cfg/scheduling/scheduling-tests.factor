USING: accessors arrays assocs compiler.cfg compiler.cfg.dependence
compiler.cfg.dependence.tests compiler.cfg.instructions
compiler.cfg.linearization compiler.cfg.registers compiler.cfg.scheduling
compiler.cfg.utilities grouping kernel math namespaces tools.test random
sequences sets splitting vectors words ;
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
    } [ [ new ] [ 2 * ] bi* >>insn# ] map-index ;

{
    {
        V{ T{ ##inc-r } T{ ##inc-d } T{ ##peek } T{ ##peek } }
        V{
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
} [ test-1187 [ f >>insn# ] map split-insns ] unit-test

{
    V{
        T{ ##load-tagged { insn# 0 } }
        T{ ##load-reference { insn# 6 } }
        T{ ##set-slot-imm { insn# 14 } }
        T{ ##replace { insn# 16 } }
    }
} [
    test-not-in-order setup-nodes [ ready? ] filter [ insn>> ] map
] unit-test

{
    V{
        T{ ##allot { insn# 2 } }
        T{ ##set-slot-imm { insn# 4 } }
        T{ ##allot { insn# 8 } }
        T{ ##set-slot-imm { insn# 10 } }
        T{ ##load-tagged { insn# 0 } }
        T{ ##load-reference { insn# 6 } }
        T{ ##set-slot-imm { insn# 12 } }
        T{ ##set-slot-imm { insn# 14 } }
        T{ ##replace { insn# 16 } }
    }
} [ test-not-in-order reorder-body ] unit-test

{ t f } [
    node new ready?
    node new { { 1 2 } } >>precedes ready?
] unit-test

{ t } [
    100 [
        test-not-in-order setup-nodes [ insn>> ] map
    ] replicate all-equal?
] unit-test

{ t } [
    100 [
        test-not-in-order setup-nodes [ score ] map
    ] replicate all-equal?
] unit-test

! You should get the exact same instruction order each time.
{ t } [
    100 [ test-not-in-order reorder-body ] replicate all-equal?
] unit-test

{ t } [
    100 [ test-1187 split-insns 1 swap nth reorder ] replicate all-equal?
] unit-test

: insns-1 ( -- insns )
    V{
        T{ ##peek { dst 275 } { loc D 2 } }
        T{ ##load-tagged { dst 277 } { val 0 } }
        T{ ##allot
           { dst 280 }
           { size 16 }
           { class-of array }
           { temp 6 }
        }
        T{ ##set-slot-imm
           { src 277 }
           { obj 280 }
           { slot 1 }
           { tag 2 }
        }
        T{ ##load-reference
           { dst 283 }
           { obj
             {
                 vector
                 2
                 1
                 tuple
                 258304024774
                 vector
                 8390923745423
             }
           }
        }
        T{ ##allot
           { dst 285 }
           { size 32 }
           { class-of tuple }
           { temp 12 }
        }
        T{ ##set-slot-imm
           { src 283 }
           { obj 285 }
           { slot 1 }
           { tag 7 }
        }
        T{ ##set-slot-imm
           { src 280 }
           { obj 285 }
           { slot 2 }
           { tag 7 }
        }
    } [ 2 * >>insn# ] map-index ;

{ t f } [
    insns-1 setup-nodes
    ! Anyone preceding insn# 14?
    [
        [ precedes>> keys [ insn>> insn#>> ] map 14 swap member? ] any?
    ]
    [
        unclip-last over swap remove-node
        [ precedes>> keys [ insn>> insn#>> ] map 14 swap member? ] any?
    ] bi
] unit-test

{ V{ 0 6 12 14 } } [
    insns-1 setup-nodes
    [ parent-index>> -1/0. = ] filter [ insn>> insn#>> ] map
] unit-test

{ 7 } [
    test-not-in-order setup-nodes
    [ parent-index>> -1/0. = ] count
] unit-test
