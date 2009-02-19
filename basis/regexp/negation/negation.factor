! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.nfa regexp.dfa regexp.minimize kernel sequences
assocs regexp.classes hashtables accessors ;
IN: regexp.negation

: ast>dfa ( parse-tree -- minimal-dfa )
    construct-nfa construct-dfa minimize ;

CONSTANT: fail-state -1

: add-default-transition ( state's-transitions -- new-state's-transitions )
    clone dup
    [ [ fail-state ] dip keys <or-class> <not-class> ] keep set-at ;

: fail-state-recurses ( transitions -- new-transitions )
    clone dup
    [ fail-state any-char associate fail-state ] dip set-at ;

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

! M: negation nfa-node ( node -- )
!     ast>dfa negate-table adjoin-dfa ;
