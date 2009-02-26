! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp regexp.private regexp.classes kernel sequences regexp.negation
quotations regexp.minimize assocs fry math locals combinators
accessors words compiler.units ;
IN: regexp.compiler

: literals>cases ( literal-transitions -- case-body )
    [ 1quotation ] assoc-map ;

: non-literals>dispatch ( non-literal-transitions -- quot )
    [ [ '[ dup _ class-member? ] ] [ 1quotation ] bi* ] assoc-map
    [ 3drop f ] suffix '[ _ cond ] ;

: split-literals ( transitions -- case default )
    ! Convert disjunction of literals to literals. Also maybe small ranges.
    >alist [ first integer? ] partition
    [ literals>cases ] [ non-literals>dispatch ] bi* ;

USING: kernel.private strings sequences.private ;

:: step ( index str case-body final? -- match? )
    index str bounds-check? [
        index 1+ str
        index str nth-unsafe
        case-body case
    ] [ final? ] if ; inline

: transitions>quot ( transitions final-state? -- quot )
    [ split-literals suffix ] dip
    '[ { array-capacity string } declare _ _ step ] ;

: word>quot ( word dfa -- quot )
    [ transitions>> at ]
    [ final-states>> key? ] 2bi
    transitions>quot ;

: states>code ( words dfa -- )
    '[
        [
            dup _ word>quot
            (( index string -- ? )) define-declared
        ] each
    ] with-compilation-unit ;

: transitions-at ( transitions assoc -- new-transitions )
    dup '[
        [ _ at ]
        [ [ _ at ] assoc-map ] bi*
    ] assoc-map ;

: states>words ( dfa -- words dfa )
    dup transitions>> keys [ gensym ] H{ } map>assoc
    [ [ transitions-at ] rewrite-transitions ]
    [ values ]
    bi swap ; 

: dfa>word ( dfa -- word )
    states>words [ states>code ] keep start-state>> ;

: run-regexp ( string word -- ? )
    [ 0 ] 2dip execute ; inline

: regexp>quotation ( regexp -- quot )
    compile-regexp dfa>> dfa>word '[ _ run-regexp ] ;
