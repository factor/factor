USING: vocabs.refresh ;
<< refresh-all >>
USING: accessors assocs benchmark.binary-trees benchmark.fannkuch
benchmark.nbody benchmark.spectral-norm compiler.cfg
compiler.cfg.debugger compiler.cfg.finalization compiler.cfg.optimizer
compiler.codegen compiler.tree.propagation compiler.tree.propagation.info
compiler.units classes.algebra compiler.tree.propagation.simple math.intervals io json kernel locals math namespaces sequences
sets tools.annotations words ;
IN: compiler-next-propagation-probe

SYMBOLS: intersections same-intersections inner-intersections same-inner
    unions same-unions class-constructions repeated-classes class-seen input-refinements entailed-refinements
    class-intersections same-class-intersections class-unions same-class-unions ;

: zero-counts ( -- )
    0 intersections set-global 0 same-intersections set-global
    0 inner-intersections set-global 0 same-inner set-global
    0 unions set-global 0 same-unions set-global
    0 class-constructions set-global 0 repeated-classes set-global
    0 class-intersections set-global 0 same-class-intersections set-global
    0 class-unions set-global 0 same-class-unions set-global
    0 input-refinements set-global 0 entailed-refinements set-global
    H{ } clone class-seen set-global ;
zero-counts

:: class-already-known? ( class value -- ? )
    value value-info* :> ( old present )
    present [
        old class>> class class<=
        old interval>> class class-interval interval-subset? and
    ] [ f ] if ;

:: count-inputs ( node infos -- )
    infos drop
    node in-d>> node word>> "input-classes" word-prop [| value class |
        input-refinements counter drop
        class value class-already-known? [ entailed-refinements counter drop ] when
    ] 2each ;

[
\ propagate [ '[ H{ } clone class-seen set-global @ ] ] annotate
\ value-info-intersect [ '[
    intersections counter drop 2dup eq? [ same-intersections counter drop ] when @
] ] annotate
\ (value-info-intersect) [ '[
    inner-intersections counter drop 2dup eq? [ same-inner counter drop ] when @
] ] annotate
\ value-info-union [ '[
    unions counter drop 2dup eq? [ same-unions counter drop ] when @
] ] annotate
\ <class-info> [ '[
    class-constructions counter drop
    dup class-seen get-global key? [ repeated-classes counter drop ] when
    dup t swap class-seen get-global set-at @
] ] annotate

\ propagate-input-infos [ '[ 2dup count-inputs @ ] ] annotate
\ class-and [ '[
    class-intersections counter drop 2dup eq? [ same-class-intersections counter drop ] when @
] ] annotate
\ class-or [ '[
    class-unions counter drop 2dup eq? [ same-class-unions counter drop ] when @
] ] annotate
] with-compilation-unit

: corpus ( -- words )
    {
        { "mismatch" "sequences" }
        { "rehash" "hashtables" }
        { "post-order" "compiler.cfg.rpo" }
        { "compute-def-use" "compiler.tree.def-use" }
        { "build-stack-frame" "compiler.cfg.build-stack-frame" }
        { "linear-scan" "compiler.cfg.linear-scan" }
        { "propagate" "compiler.tree.propagation" }
        { "build-tree" "compiler.tree.builder" }
        { "generate" "compiler.codegen" }
        { "spectral-norm" "benchmark.spectral-norm" }
        { "nbody" "benchmark.nbody" }
        { "fannkuch" "benchmark.fannkuch" }
        { "binary-trees-benchmark" "benchmark.binary-trees" }
    } [ first2 lookup-word ] map ;

: compile-body ( word -- )
    [ test-builder [ dup cfg namespaces:set dup optimize-cfg dup finalize-cfg generate drop ] each ] with-scope ;

:: probe ( word -- )
    zero-counts
    word compile-body
    H{ } clone :> result
    word name>> "word" result set-at
    {
        intersections same-intersections inner-intersections same-inner
        unions same-unions class-constructions repeated-classes
        input-refinements entailed-refinements
        class-intersections same-class-intersections class-unions same-class-unions
    } [ dup get-global swap name>> result set-at ] each
    result >json print flush ;
corpus [ probe ] each
