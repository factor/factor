! Definitions and handles only. Invoke WORK words after compilation finishes.
USING: parser ;
<< "reference/compiler-next3-loops-20260909/workloads.factor" run-file
   "reference/compiler-next3-representations-20260909/workloads.factor" run-file
   "reference/compiler-next3-vectorization-20260909/kernels.factor" run-file
   "reference/compiler-next3-vectorization-20260909/workload.factor" run-file >>
USING: compiler-next3.benchmark compiler-next3-representation-workload
compiler.cfg.memory-optimization.validation compiler.loop-witness
benchmark.scalar-mixing kernel namespaces words ;
IN: compiler-next3.witnesses
SYMBOLS: selected-loop-kernel selected-memory-kernel ;
\ invariant-xor-loop "typed-word" word-prop selected-loop-kernel set-global
\ memory-loop-work "typed-word" word-prop selected-memory-kernel set-global
: loop-work ( -- )
    123 456 10000001 selected-loop-kernel get execute( x y n -- result )
    435 assert= ;
: memory-work ( -- )
    38 <memory-cell> 1000003 selected-memory-kernel get execute( cell n -- result )
    38 assert= ;

! SLP WORK is supplied by the frozen vectorization witness file.
"loops" \ loop-work selected-loop-kernel get-global 10 register-witness
"representations" \ representation-loop-work \ representation-loop-values 50 register-witness
"memory" \ memory-work selected-memory-kernel get-global 10 register-witness

prepare-mixing-oracle
"slp" \ mixing-work \ mixing-pair 50 register-witness
