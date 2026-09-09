USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays compiler.units assocs compiler.cfg.loop-optimization compiler.cfg.checker
compiler.cfg.optimizer compiler.cfg.alias-analysis compiler.cfg.ssa.construction
compiler.cfg.copy-prop compiler.cfg.multiply-negate compiler.cfg.dce
compiler.cfg.value-numbering compiler.cfg.register-allocation.verifier
compiler.cfg.register-allocation.verifier.rematerialization
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.backtracking compiler.cfg.register-allocation.chordal
compiler.test io kernel locals math math.bitwise namespaces prettyprint
sequences system tools.test typed words parser ;
<< "reference/compiler-next3-loops-20260909/workloads.factor" run-file >>
USE: compiler.loop-witness
IN: compiler.loop-source-probe
SYMBOL: source-hoists
V{ } clone source-hoists set-global
<< \ source-hoists \ perform-loop-optimization def>> "original-pass" set-word-prop >>
USE: compiler.loop-source-probe
IN: compiler.cfg.loop-optimization
: perform-loop-optimization ( cfg -- )
    \ source-hoists "original-pass" word-prop call( cfg -- )
    "hoisted" loop-optimization-statistics get at 0 or
    source-hoists get push ;
IN: compiler.loop-source-probe
f global-value-numbering? set-global
f rematerialize-constants? set-global
t check-ssa? set-global t check-allocation? set-global
t loop-optimization? set-global
value-flow-verifier-enabled? t assert=
f restartable-tests? set-global
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator } [| allocator |
    allocator register-allocator set-global
    { f t } [| remat? |
        remat? rematerialize-constants? set-global
        { f t } [| gvn? |
            gvn? global-value-numbering? set-global
            source-hoists get delete-all
            \ invariant-xor-loop "typed-word" word-prop 1array compile
            allocator remat? gvn? source-hoists get sum 4array .
            gvn? [ ] [ source-hoists get sum 0 > t assert= ] if
            { 0 1 2 4 7 19 } [| n |
                { -7 0 37 } [| x |
                    { -3 0 11 } [| y |
                        x y n invariant-xor-loop
                        n odd? [ x y bitxor ] [ 0 ] if assert=
                    ] each
                ] each
            ] each
        ] each
    ] each
] each
test-failures get empty? t assert=
"LICM SOURCE PASS: 16 configurations / 864 native answers" print
0 exit
