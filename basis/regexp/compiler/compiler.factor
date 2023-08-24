! Copyright (C) 2009 Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
kernel kernel.private math namespaces quotations regexp.classes
regexp.transition-tables sequences sequences.private sets
strings unicode words ;
IN: regexp.compiler

GENERIC: question>quot ( question -- quot )

SYMBOL: shortest?
SYMBOL: backwards?

<PRIVATE

M: t question>quot drop [ 2drop t ] ;
M: f question>quot drop [ 2drop f ] ;

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

M: $crlf question>quot
    drop [ { [ length = ] [ ?nth "\r\n" member? ] } 2|| ] ;

M: ^crlf question>quot
    drop [ { [ drop zero? ] [ [ 1 - ] dip ?nth "\r\n" member? ] } 2|| ] ;

M: $unix question>quot
    drop [ { [ length = ] [ ?nth CHAR: \n = ] } 2|| ] ;

M: ^unix question>quot
    drop [ { [ drop zero? ] [ [ 1 - ] dip ?nth CHAR: \n = ] } 2|| ] ;

M: word-break question>quot
    drop [ word-break-at? ] ;

: (execution-quot) ( next-state -- quot )
    ! The conditions here are for lookaround and anchors, etc
    dup condition? [
        [ question>> question>quot ] [ yes>> ] [ no>> ] tri
        [ (execution-quot) ] bi@
        '[ 2dup @ _ _ if ]
    ] [ 1quotation ] if ;

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

: split-literals ( transitions -- case default )
    { } assoc-like [ first integer? ] partition
    [ [ literals>cases ] keep ] dip non-literals>dispatch ;

: advance ( index backwards? -- index+/-1 )
    -1 1 ? + >fixnum ; inline

: check ( index string backwards? -- in-bounds? )
    [ drop -1 eq? not ] [ length < ] if ; inline

:: step ( last-match index str quot final? backwards? -- last-index/f )
    final? index last-match ?
    index str backwards? check [
        index backwards? advance str
        index str nth-unsafe
        quot call
    ] when ; inline

: transitions>quot ( transitions final-state? -- quot )
    dup shortest? get and [ 2drop [ drop nip ] ] [
        [ split-literals swap case>quot ] dip backwards? get
        '[ { fixnum string } declare _ _ _ step ]
    ] if ;

: word>quot ( word dfa -- quot )
    [ transitions>> at ]
    [ final-states>> in? ] 2bi
    transitions>quot ;

: states>code ( words dfa -- )
    '[
        dup _ word>quot
        ( last-match index string -- ? )
        define-declared
    ] each ;

: states>words ( dfa -- words dfa )
    dup transitions>> keys [ gensym ] H{ } map>assoc
    [ transitions-at ]
    [ values ]
    bi swap ;

: dfa>main-word ( dfa -- word )
    states>words [ states>code ] keep start-state>> ;

: word-template ( quot -- quot' )
    '[ drop [ f ] 2dip over array-capacity? _ [ 2drop ] if ] ;

PRIVATE>

: dfa>word ( dfa -- quot )
    dfa>main-word execution-quot word-template
    ( start-index string regexp -- i/f ) define-temp ;

: dfa>shortest-word ( dfa -- word )
    t shortest? [ dfa>word ] with-variable ;

: dfa>reverse-word ( dfa -- word )
    t backwards? [ dfa>word ] with-variable ;

: dfa>reverse-shortest-word ( dfa -- word )
    t backwards? [ dfa>shortest-word ] with-variable ;
