! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.nfa regexp.disambiguate kernel sequences
assocs regexp.classes hashtables accessors fry vectors
regexp.ast regexp.transition-tables regexp.minimize
regexp.dfa namespaces sets ;
IN: regexp.negation

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

: inverse-final-states ( transition-table -- final-states )
    [ transitions>> keys ] [ final-states>> ] bi diff fast-set ;

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
    dup [ final-states>> members ] keep
    '[ -2 epsilon _ set-transition ] each
    HS{ -2 } clone >>final-states ;

: adjoin-dfa ( transition-table -- start end )
    unify-final-state renumber-states box-transitions 
    [ start-state>> ]
    [ final-states>> members first ]
    [ nfa-table get [ transitions>> ] bi@ swap assoc-union! drop ] tri ;

: ast>dfa ( parse-tree -- minimal-dfa )
    construct-nfa disambiguate construct-dfa minimize ;

M: negation nfa-node ( node -- start end )
    term>> ast>dfa negate-table adjoin-dfa ;
