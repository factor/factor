! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: regexp.classes kernel sequences regexp.negation
quotations regexp.minimize assocs fry math locals combinators
accessors words compiler.units kernel.private strings
sequences.private arrays regexp.matchers call namespaces
regexp.transition-tables combinators.short-circuit ;
IN: regexp.compiler

GENERIC: question>quot ( question -- quot )

<PRIVATE

SYMBOL: shortest?
SYMBOL: backwards?

M: t question>quot drop [ 2drop t ] ;

M: beginning-of-input question>quot
    drop [ drop zero? ] ;

M: end-of-input question>quot
    drop [ length = ] ;

M: end-of-file question>quot
    drop [
        {
            [ length swap - 2 <= ]
            [ swap tail { "\n" "\r\n" "\r" "" } member? ]
        } 2&&
    ] ;

M: $ question>quot
    drop [ { [ length = ] [ ?nth "\r\n" member? ] } 2|| ] ;

M: ^ question>quot
    drop [ { [ drop zero? ] [ [ 1- ] dip ?nth "\r\n" member? ] } 2|| ] ;

: (execution-quot) ( next-state -- quot )
    ! The conditions here are for lookaround and anchors, etc
    dup condition? [
        [ question>> question>quot ] [ yes>> ] [ no>> ] tri
        [ (execution-quot) ] bi@
        '[ 2dup @ _ _ if ]
    ] [ '[ _ execute ] ] if ;

: execution-quot ( next-state -- quot )
    dup sequence? [ first ] when
    (execution-quot) ;

TUPLE: box contents ;
C: <box> box

: condition>quot ( condition -- quot )
    ! Conditions here are for different classes
    dup condition? [
        [ question>> ] [ yes>> ] [ no>> ] tri
        [ condition>quot ] bi@
        '[ dup _ class-member? _ _ if ]
    ] [
        contents>>
        [ [ 3drop ] ] [ execution-quot '[ drop @ ] ] if-empty
    ] if ;

: non-literals>dispatch ( literals non-literals  -- quot )
    [ swap ] assoc-map ! we want state => predicate, and get the opposite as input
    swap keys f assoc-answers
    table>condition [ <box> ] condition-map condition>quot ;

: literals>cases ( literal-transitions -- case-body )
    [ execution-quot ] assoc-map ;

: expand-one-or ( or-class transition -- alist )
    [ seq>> ] dip '[ _ 2array ] map ;

: expand-or ( alist -- new-alist )
    [
        first2 over or-class?
        [ expand-one-or ] [ 2array 1array ] if
    ] map concat ;

: split-literals ( transitions -- case default )
    >alist expand-or [ first integer? ] partition
    [ [ literals>cases ] keep ] dip non-literals>dispatch ;

:: step ( last-match index str quot final? direction -- last-index/f )
    final? index last-match ?
    index str bounds-check? [
        index direction + str
        index str nth-unsafe
        quot call
    ] when ; inline

: direction ( -- n )
    backwards? get -1 1 ? ;

: transitions>quot ( transitions final-state? -- quot )
    dup shortest? get and [ 2drop [ drop nip ] ] [
        [ split-literals swap case>quot ] dip direction
        '[ { array-capacity string } declare _ _ _ step ]
    ] if ;

: word>quot ( word dfa -- quot )
    [ transitions>> at ]
    [ final-states>> key? ] 2bi
    transitions>quot ;

: states>code ( words dfa -- )
    [ ! with-compilation-unit doesn't compile, so we need call( -- )
        [
            '[
                dup _ word>quot
                (( last-match index string -- ? ))
                define-declared
            ] each
        ] with-compilation-unit
    ] call( words dfa -- ) ;

: states>words ( dfa -- words dfa )
    dup transitions>> keys [ gensym ] H{ } map>assoc
    [ transitions-at ]
    [ values ]
    bi swap ; 

: dfa>word ( dfa -- word )
    states>words [ states>code ] keep start-state>> ;

: check-string ( string -- string )
    ! Make this configurable
    dup string? [ "String required" throw ] unless ;

: setup-regexp ( start-index string -- f start-index string )
    [ f ] [ >fixnum ] [ check-string ] tri* ; inline

PRIVATE>

! The quotation returned is ( start-index string -- i/f )

: dfa>quotation ( dfa -- quot )
    dfa>word execution-quot '[ setup-regexp @ ] ;

: dfa>shortest-quotation ( dfa -- quot )
    t shortest? [ dfa>quotation ] with-variable ;

: dfa>reverse-quotation ( dfa -- quot )
    t backwards? [ dfa>quotation ] with-variable ;

: dfa>reverse-shortest-quotation ( dfa -- quot )
    t backwards? [ dfa>shortest-quotation ] with-variable ;

TUPLE: quot-matcher quot ;
C: <quot-matcher> quot-matcher

M: quot-matcher match-index-from
    quot>> call( index string -- i/f ) ;
