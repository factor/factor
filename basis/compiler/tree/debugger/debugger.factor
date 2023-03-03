! Copyright (C) 2006, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators
combinators.short-circuit compiler.tree compiler.tree.builder
compiler.tree.cleanup compiler.tree.combinators
compiler.tree.dead-code compiler.tree.def-use
compiler.tree.escape-analysis compiler.tree.identities
compiler.tree.modular-arithmetic compiler.tree.normalization
compiler.tree.optimizer compiler.tree.propagation
compiler.tree.recursive compiler.tree.tuple-unboxing effects
generic hints io kernel make match math namespaces prettyprint
prettyprint.config prettyprint.custom prettyprint.sections
quotations sequences sequences.private sets sorting words ;
FROM: syntax => _ ;
RENAME: _ match => __
IN: compiler.tree.debugger

! A simple tool for turning tree IR into quotations and
! printing reports, for debugging purposes.

GENERIC: node>quot ( node -- )

MACRO: match-choose ( alist -- quot )
    [ '[ _ ] ] assoc-map '[ _ match-cond ] ;

MATCH-VARS: ?a ?b ?c ;

: pretty-shuffle ( effect -- word/f )
    [ in>> ] [ out>> ] bi 2array {
        { { { } { } } [ ] }
        { { { ?a } { ?a } } [ ] }
        { { { ?a ?b } { ?a ?b } } [ ] }
        { { { ?a ?b ?c } { ?a ?b ?c } } [ ] }
        { { { ?a } { } } [ drop ] }
        { { { ?a ?b } { } } [ 2drop ] }
        { { { ?a ?b ?c } { } } [ 3drop ] }
        { { { ?a } { ?a ?a } } [ dup ] }
        { { { ?a ?b } { ?a ?b ?a ?b } } [ 2dup ] }
        { { { ?a ?b ?c } { ?a ?b ?c ?a ?b ?c } } [ 3dup ] }
        { { { ?a ?b } { ?a ?b ?a } } [ over ] }
        { { { ?b ?a } { ?a ?b } } [ swap ] }
        { { { ?b ?a ?c } { ?a ?b ?c } } [ swapd ] }
        { { { ?a ?b } { ?a ?a ?b } } [ dupd ] }
        { { { ?a ?b ?c } { ?a ?b ?c ?a } } [ pick ] }
        { { { ?a ?b ?c } { ?c ?a ?b } } [ -rot ] }
        { { { ?a ?b ?c } { ?b ?c ?a } } [ rot ] }
        { { { ?a ?b } { ?b } } [ nip ] }
        { { { ?a ?b ?c } { ?c } } [ 2nip ] }
        { __ f }
    } match-choose ;

TUPLE: shuffle-node { effect effect } ;

M: shuffle-node pprint* effect>> effect>string text ;

: (shuffle-effect) ( in out #shuffle -- effect )
    mapping>> '[ _ at ] map [ >array ] bi@ <effect> ;

: shuffle-effect ( #shuffle -- effect )
    [ in-d>> ] [ out-d>> ] [ ] tri (shuffle-effect) ;

: #>r? ( #shuffle -- ? )
    {
        [ in-d>> length 1 = ]
        [ out-r>> length 1 = ]
        [ in-r>> empty? ]
        [ out-d>> empty? ]
    } 1&& ;

: #r>? ( #shuffle -- ? )
    {
        [ in-d>> empty? ]
        [ out-r>> empty? ]
        [ in-r>> length 1 = ]
        [ out-d>> length 1 = ]
    } 1&& ;

SYMBOLS: >R R> ;

M: #shuffle node>quot
    {
        { [ dup #>r? ] [ drop \ >R , ] }
        { [ dup #r>? ] [ drop \ R> , ] }
        {
            [ dup { [ in-r>> empty? ] [ out-r>> empty? ] } 1&& ]
            [
                shuffle-effect
                [ pretty-shuffle ] [ % ] [ shuffle-node boa , ] ?if
            ]
        }
        [ drop "COMPLEX SHUFFLE" , ]
    } cond ;

M: #push node>quot literal>> literalize , ;

M: #call node>quot word>> , ;

M: #call-recursive node>quot label>> id>> , ;

DEFER: nodes>quot

DEFER: label

M: #recursive node>quot
    [ label>> id>> literalize , ]
    [ child>> nodes>quot , \ label , ]
    bi ;

M: #if node>quot
    children>> [ nodes>quot ] map % \ if , ;

M: #dispatch node>quot
    children>> [ nodes>quot ] map , \ dispatch , ;

M: #alien-invoke node>quot params>> , #alien-invoke , ;

M: #alien-indirect node>quot params>> , #alien-indirect , ;

M: #alien-assembly node>quot params>> , #alien-assembly , ;

M: #alien-callback node>quot
    [ params>> , ] [ child>> nodes>quot , ] bi #alien-callback , ;

M: node node>quot drop ;

: nodes>quot ( node -- quot )
    [ [ node>quot ] each ] [ ] make ;

GENERIC: optimized. ( quot/word -- )

M: word optimized. specialized-def optimized. ;

M: callable optimized.
    build-tree optimize-tree nodes>quot
    f length-limit [ . ] with-variable ;

SYMBOL: words-called
SYMBOL: generics-called
SYMBOL: methods-called
SYMBOL: intrinsics-called
SYMBOL: node-count

: make-report ( word/quot -- assoc )
    [
        build-tree optimize-tree

        H{ } clone words-called ,,
        H{ } clone generics-called ,,
        H{ } clone methods-called ,,
        H{ } clone intrinsics-called ,,

        0 swap [
            [ 1 + ] dip
            dup #call? [
                word>> {
                    { [ dup "intrinsic" word-prop ] [ intrinsics-called ] }
                    { [ dup generic? ] [ generics-called ] }
                    { [ dup method? ] [ methods-called ] }
                    [ words-called ]
                } cond building get at inc-at
            ] [ drop ] if
        ] each-node
        node-count ,,
    ] H{ } make ;

: report. ( report -- )
    [
        "==== Total number of IR nodes:" print
        node-count get .

        {
            { generics-called "==== Generic word calls:" }
            { words-called "==== Ordinary word calls:" }
            { methods-called "==== Non-inlined method calls:" }
            { intrinsics-called "==== Open-coded intrinsic calls:" }
        } [
            nl print get keys sort stack.
        ] assoc-each
    ] with-variables ;

: optimizer-report. ( word -- )
    make-report report. ;

! More utilities
: cleaned-up-tree ( quot -- nodes )
    [
        build-tree
        analyze-recursive
        normalize
        propagate
        cleanup-tree
        escape-analysis
        unbox-tuples
        apply-identities
        compute-def-use
        remove-dead-code
        compute-def-use
        optimize-modular-arithmetic
    ] with-scope ;

: inlined? ( quot seq/word -- ? )
    dup word? [ 1array ] when swap
    [ cleaned-up-tree [ dup #call? [ word>> , ] [ drop ] if ] each-node ] V{ } make
    intersect empty? ;
