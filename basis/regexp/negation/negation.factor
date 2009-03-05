! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.nfa regexp.disambiguate kernel sequences
assocs regexp.classes hashtables accessors fry vectors
regexp.ast regexp.transition-tables regexp.minimize
regexp.dfa namespaces ;
IN: regexp.negation

: ast>dfa ( parse-tree -- minimal-dfa )
    construct-nfa disambiguate construct-dfa minimize ;

CONSTANT: fail-state -1

: add-default-transition ( state's-transitions -- new-state's-transitions )
    clone dup
    [ [ fail-state ] dip keys [ <not-class> ] map <and-class> ] keep set-at ;

: fail-state-recurses ( transitions -- new-transitions )
    clone dup
    [ fail-state t associate fail-state ] dip set-at ;

: add-fail-state ( transitions -- new-transitions )
    [ add-default-transition ] assoc-map
    fail-state-recurses ;

: assoc>set ( assoc -- keys-set )
    [ drop dup ] assoc-map ;

: inverse-final-states ( transition-table -- final-states )
    [ transitions>> assoc>set ] [ final-states>> ] bi assoc-diff ;

: negate-table ( transition-table -- transition-table )
    clone
        [ add-fail-state ] change-transitions
        dup inverse-final-states >>final-states ;

: renumber-states ( transition-table -- transition-table )
    dup transitions>> keys [ next-state ] H{ } map>assoc
    transitions-at ;

: box-transitions ( transition-table -- transition-table )
    [ [ [ 1vector ] assoc-map ] assoc-map ] change-transitions ;

: unify-final-state ( transition-table -- transition-table )
    dup [ final-states>> keys ] keep
    '[ -2 epsilon _ add-transition ] each
    H{ { -2 -2 } } >>final-states ;

: adjoin-dfa ( transition-table -- start end )
    box-transitions unify-final-state renumber-states
    [ start-state>> ]
    [ final-states>> keys first ]
    [ nfa-table get [ transitions>> ] bi@ swap update ] tri ;

M: negation nfa-node ( node -- start end )
    term>> ast>dfa negate-table adjoin-dfa ;
