USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.spilling
compiler.cfg.linear-scan.allocation.state compiler.cfg.linear-scan.assignment
compiler.cfg.linear-scan.live-intervals compiler.cfg.linear-scan.numbering
compiler.cfg.linear-scan.resolve compiler.cfg.linearization
compiler.cfg.metrics compiler.cfg.register-allocation
compiler.cfg.register-allocation.backtracking
compiler.cfg.register-allocation.chordal compiler.cfg.register-allocation.greedy
compiler.cfg.register-allocation.rematerialization
compiler.cfg.register-allocation.verifier compiler.cfg.registers
compiler.cfg.ssa.destruction.leaders compiler.cfg.utilities
compiler.codegen compiler.test compiler.units cpu.architecture hashtables
kernel layouts locals make math
math.private memory namespaces sequences tools.test words ;
USING: compiler.cfg.checker compiler.cfg.value-numbering
compiler.cfg.register-allocation.verifier.rematerialization json io ;
IN: allocator-rematerialization-metrics
: init-pressure-representations ( -- )
    H{ } clone representations set
    200 <iota> [ int-rep swap set-rep-of ] each
    200 vreg-counter set ;

: emit-pressure-constants ( -- )
    40 <iota> [ dup 1 + tag-fixnum ##load-integer, ] each ;

:: emit-pressure-sum ( base -- result )
    base 0 1 ##add,
    38 <iota> [| i | i base + 1 + i base + i 2 + ##add, ] each
    base 38 + ;

:: <constant-pressure-cfg> ( -- cfg )
    init-pressure-representations
    [
        ##prologue,
        emit-pressure-constants
        40 emit-pressure-sum D: 0 ##replace,
        ##epilogue,
        ##return,
    ] { } make insns>cfg ;

! Include MOVN/sign-extension cases under actual pressure. Values are
! tagged fixnum bits so the machine result remains an ordinary Factor
! integer: ten repetitions of (-2048 -1 0 2047) sum to -20.
: <signed-constant-pressure-cfg> ( -- cfg )
    <constant-pressure-cfg> dup cfg>insns
    [ ##load-integer? ] filter
    [ dup dst>> 4 mod { -32768 -16 0 32752 } nth >>val drop ] each ;

:: pressure-metrics ( allocator enabled? -- metrics )
    [
        enabled? rematerialize-constants? set
        allocator register-allocator set
        t check-allocation? set
        <constant-pressure-cfg> :> graph
        graph cfg set
        graph allocate-registers
        graph build-stack-frame
        graph cfg-metrics :> metrics
        graph generate 4 swap nth length "code-bytes" metrics set-at
        rematerialization-count "rematerializations" metrics set-at
        allocator allocator-statistics "allocator-statistics" metrics set-at
        allocator name>> "allocator" metrics set-at
        enabled? "rematerialize" metrics set-at
        metrics
    ] with-scope ;


t check-ssa? set-global
f global-value-numbering? set-global
{ linear-scan-allocator greedy-allocator backtracking-allocator chordal-allocator }
[| allocator |
    { f t } [| enabled? |
        allocator enabled? pressure-metrics >json print flush
    ] each
] each
