! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.classes kernel sequences regexp.negation
quotations regexp.minimize assocs fry math locals combinators
accessors words compiler.units kernel.private strings
sequences.private arrays regexp.matchers call ;
IN: regexp.compiler

: literals>cases ( literal-transitions -- case-body )
    [ 1quotation ] assoc-map ;

: condition>quot ( condition -- quot )
    dup condition? [
        [ question>> ] [ yes>> ] [ no>> ] tri
        [ condition>quot ] bi@
        '[ dup _ class-member? _ _ if ]
    ] [
        [ [ 3drop ] ] [ '[ drop _ execute ] ] if-empty
    ] if ;

: new-non-literals>dispatch ( non-literal-transitions -- quot )
    table>condition condition>quot ;

: non-literals>dispatch ( non-literal-transitions -- quot )
    [ [ '[ dup _ class-member? ] ] [ '[ drop _ execute ] ] bi* ] assoc-map
    [ 3drop ] suffix '[ _ cond ] ;

: expand-one-or ( or-class transition -- alist )
    [ seq>> ] dip '[ _ 2array ] map ;

: expand-or ( alist -- new-alist )
    [
        first2 over or-class?
        [ expand-one-or ] [ 2array 1array ] if
    ] map concat ;

: split-literals ( transitions -- case default )
    >alist expand-or [ first integer? ] partition
    [ literals>cases ] [ non-literals>dispatch ] bi* ;

:: step ( last-match index str case-body final? -- last-index/f )
    final? index last-match ?
    index str bounds-check? [
        index 1+ str
        index str nth-unsafe
        case-body case
    ] when ; inline

: transitions>quot ( transitions final-state? -- quot )
    [ split-literals suffix ] dip
    '[ { array-capacity sequence } declare _ _ step ] ;

: word>quot ( word dfa -- quot )
    [ transitions>> at ]
    [ final-states>> key? ] 2bi
    transitions>quot ;

: states>code ( words dfa -- )
    '[
        [
            dup _ word>quot
            (( last-match index string -- ? ))
            define-declared
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

: check-sequence ( string -- string )
    ! Make this configurable
    dup sequence? [ "String required" throw ] unless ;

: run-regexp ( start-index string word -- ? )
    { [ f ] [ >fixnum ] [ check-sequence ] [ execute ] } spread ; inline

: dfa>quotation ( dfa -- quot )
    dfa>word '[ _ run-regexp ] ;

TUPLE: quot-matcher quot ;
C: <quot-matcher> quot-matcher

M: quot-matcher match-index-from
    quot>> call( index string -- i/f ) ;
