! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs hashtables kernel namespaces regexp.ast
regexp.classes regexp.dfa regexp.disambiguate regexp.minimize
regexp.nfa regexp.transition-tables sequences sets vectors ;
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

: ast>nfa ( parse-tree -- minimal-dfa )
    construct-nfa disambiguate ;

: ast>dfa ( parse-tree -- minimal-dfa )
    ast>nfa construct-dfa minimize ;

M: negation nfa-node
    term>> ast>dfa negate-table adjoin-dfa ;
