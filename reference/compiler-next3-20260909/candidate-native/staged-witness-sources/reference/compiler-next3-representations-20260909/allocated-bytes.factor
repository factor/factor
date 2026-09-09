USING: vocabs.loader vocabs.refresh ;
<< refresh-all >>
USING: accessors arrays assocs compiler.cfg.checker
compiler.cfg.linear-scan.allocation.state compiler.cfg.register-allocation.verifier
compiler.cfg.representations.selection compiler.cfg.value-numbering
compiler.units io json kernel kernel.private locals math math.private memory
namespaces quotations sequences sequences.generalizations stack-checker system
tools.memory words ;
IN: representation-allocation-probe

: repeated-loop-quot ( -- quot )
    [ { fixnum } declare 0.0 swap [ 1.0 float+ ] times ]
    31 [ \ dup ] replicate append [ 32 narray ] append >quotation ;

:: allocated-bytes ( n word -- bytes )
    32 [ n >float ] replicate :> expected
    gc
    [
        data-room nursery>> occupied>> :> before
        n word execute( n -- values )
        expected assert=
        data-room nursery>> occupied>> before -
    ] collect-gc-events
    empty? t assert= ;

:: measure-allocation ( enabled? -- )
    enabled? conversion-aware-representation-costs? set
    [ repeated-loop-quot dup infer define-temp ] with-compilation-unit :> word
    0 word allocated-bytes drop
    1000 word allocated-bytes drop
    0 word allocated-bytes :> zero
    1000 word allocated-bytes :> thousand
    H{ { "enabled" enabled? } { "zero-iterations-bytes" zero }
       { "thousand-iterations-bytes" thousand } } >json print flush ;

t check-allocation? set-global
t check-ssa? set-global
f global-value-numbering? set-global
f measure-allocation
t measure-allocation
0 exit
