USING: accessors compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.instructions compiler.cfg.linear-scan.allocation.state
compiler.cfg.memory-optimization compiler.cfg.memory-optimization.validation
compiler.cfg.register-allocation compiler.cfg.register-allocation.verifier
compiler.cfg.utilities kernel locals math math.bitwise namespaces sequences tools.test ;
IN: compiler.cfg.memory-optimization.validation.tests

! Ordinary source is a productive witness after all existing SSA passes.
{ t } [ [ [let
    f memory-optimization? set
    [ memory-branch ] test-ssa [| graph |
        graph eliminate-redundant-loads
        graph check-ssa
    ] any?
] ] with-scope ] unit-test

! Fresh code under each setting, independent expected answers and observable
! mutation. Equal object identities are tested as well as disjoint objects.
{ t } [ [ [let
    t check-ssa? set t check-allocation? set
    linear-scan-allocator register-allocator set
    value-flow-verifier-enabled? t assert=
    { f t } [| enabled? |
        enabled? memory-optimization? set
        [ memory-branch ] fresh-memory-word :> branch
        [ memory-alias-branch ] fresh-memory-word :> aliases
        [ memory-alias-loop ] fresh-memory-word :> loop
        { -19 0 7 38 } [| seed |
            { f t } [| flag |
                seed <memory-cell> flag branch execute( cell flag -- result )
                seed seed flag 3 1 ? bitand bitxor =
                { f t } [| same? |
                    seed <memory-cell> :> a
                    same? [ a ] [ 55 <memory-cell> ] if :> b
                    a b flag aliases execute( a b flag -- result )
                    seed flag same? and 91 seed ? bitxor =
                    b value>> flag 91 same? seed 55 ? ? = and
                ] all? and
            ] all?
            { 0 1 2 7 } [| n |
                { f t } [| same? |
                    seed <memory-cell> :> a
                    same? [ a ] [ 55 <memory-cell> ] if :> b
                    a b n loop execute( a b n -- result )
                    seed n 0 > same? and n 1 - seed ? bitxor =
                    b value>> n 0 > n 1 - same? seed 55 ? ? = and
                ] all?
            ] all? and
        ] all?
    ] all?
] ] with-scope ] unit-test
