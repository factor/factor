USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors compiler.cfg.checker compiler.cfg.instructions
compiler.cfg.linear-scan.allocation.state compiler.cfg.memory-optimization
compiler.cfg.memory-optimization.private compiler.cfg.memory-optimization.validation
compiler.cfg.optimizer compiler.cfg.register-allocation
compiler.cfg.register-allocation.verifier io kernel math.bitwise namespaces parser
prettyprint system words ;
IN: compiler.cfg.optimizer
SYMBOL: mutation-original-ssa
<< \ optimize-ssa def>> \ mutation-original-ssa set-global >>
: optimize-ssa ( cfg -- )
    dup mutation-original-ssa get call( cfg -- ) dup optimize-memory check-ssa ;
IN: compiler.cfg.memory-optimization.private
SYMBOL: mutation-original-update
<< \ update-memory-facts def>> \ mutation-original-update set-global >>
: update-memory-facts ( insn facts -- )
    over [ write-insn? ] [ ##write-barrier? ] [ ##write-barrier-imm? ] tri or or
    [ 2drop ] [ mutation-original-update get call( insn facts -- ) ] if ;
IN: compiler.cfg.memory-optimization.validation
! This process intentionally installs an unsound test mutant which forgets
! managed writes. A real aliasing native oracle must distinguish its result.
! Never load this script into a benchmark or development image.
t check-ssa? set-global t check-allocation? set-global
t memory-optimization? set-global
linear-scan-allocator register-allocator set-global
value-flow-verifier-enabled? t assert=
[let
    [ memory-alias-branch ] fresh-memory-word :> word
    17 <memory-cell> :> cell
    cell cell t word execute( a b flag -- result ) :> observed
    17 91 bitxor :> expected
    observed 0 assert=
    observed expected = f assert=
    cell value>> 91 assert=
    "UNSOUND MUTANT NATIVE RESULT " write observed .
    "INDEPENDENT EXPECTED RESULT " write expected .
]
"MEMORY MUTATION CONTROL PASS: native oracle rejects ignored aliased store" print
0 exit
