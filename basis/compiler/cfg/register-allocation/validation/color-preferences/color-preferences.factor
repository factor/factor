! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs compiler.cfg.register-allocation.chordal
compiler.cfg.registers continuations cpu.architecture hashtables kernel locals
math math.bitwise namespaces sequences sets sorting ;
IN: compiler.cfg.register-allocation.validation.color-preferences

! Keep the former lexicographic selection as an independent oracle. The
! production helper assumes ascending free colors, as supplied by <iota>.
:: sorted-preference-color ( free preferences shared -- color )
    free [| color |
        color preferences at 0 or color shared at 0 or + neg color 2array
    ] sort-by first ;

:: sorted-preference-colors ( graph order affinities available -- colors )
    H{ } clone :> colors
    graph keys [ H{ } clone ] H{ } map>assoc :> preferences
    affinities affinity-chunks :> chunks
    chunks values [ first ] map members
    [ H{ } clone ] H{ } map>assoc :> chunk-preferences
    order [| vertex |
        vertex chunks at first chunk-preferences at :> shared
        vertex graph at [ colors at ] map sift :> occupied
        vertex rep-of reg-class-of available at length :> capacity
        capacity <iota> [ occupied member? not ] filter :> free
        free empty? [ vertex occupied capacity uncolorable-spill-result ] when
        free vertex preferences at shared sorted-preference-color :> chosen
        chosen vertex colors set-at
        chosen shared inc-at
        vertex affinities at [| partner weight |
            chosen partner preferences at [ 0 or weight 8 * + ] change-at
        ] assoc-each
    ] each
    colors ;

CONSTANT: preference-edges { { 0 1 } { 0 2 } { 0 3 } { 1 2 } { 1 3 } { 2 3 } }

:: preference-test-graph ( mask -- graph )
    4 <iota> [ V{ } clone ] H{ } map>assoc :> graph
    preference-edges [| pair index |
        mask 1 index shift bitand 0 > [
            pair first2 graph at push
            pair reverse first2 graph at push
        ] when
    ] each-index
    graph ;

:: preference-test-affinities ( seed -- affinities )
    4 <iota> [ H{ } clone ] H{ } map>assoc :> affinities
    preference-edges [| pair index |
        seed 1 index shift bitand 0 > [
            { 1/8 1 8 } index 3 mod swap nth :> weight
            pair first2 :> ( a b )
            weight a b affinities at set-at
            weight b a affinities at set-at
        ] when
    ] each-index
    affinities ;

! Returning f denotes the same explicit exhaustion error, never a fallback
! coloring. Unexpected exceptions still fail the differential corpus.
: preference-result ( ... quot -- ... colors/f )
    [ dup uncolorable-spill-result? [ drop f ] [ rethrow ] if ] recover ; inline

:: compare-preference-colorings ( graph order affinities capacity -- ? )
    capacity <iota> >array int-regs associate :> available
    [ graph order affinities available preference-guided-colors ] preference-result
    [ graph order affinities available sorted-preference-colors ] preference-result = ;
