! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel locals math namespaces
sequences fry quotations math.order math.ranges vectors
unicode.categories regexp.transition-tables words sets hashtables
combinators.short-circuit unicode.data regexp.ast
regexp.classes memoize ;
IN: regexp.nfa

! This uses unicode.data for ch>upper and ch>lower
! but case-insensitive matching should be done by case-folding everything
! before processing starts

SYMBOL: option-stack

SYMBOL: state

: next-state ( -- state )
    state [ get ] [ inc ] bi ;

SYMBOL: nfa-table

: set-each ( keys value hashtable -- )
    '[ _ swap _ set-at ] each ;

: options>hash ( options -- hashtable )
    H{ } clone [
        [ [ on>> t ] dip set-each ]
        [ [ off>> f ] dip set-each ] 2bi
    ] keep ;

: using-options ( options quot -- )
    [ options>hash option-stack [ ?push ] change ] dip
    call option-stack get pop* ; inline

: option? ( obj -- ? )
    option-stack get assoc-stack ;

GENERIC: nfa-node ( node -- start-state end-state )

: add-simple-entry ( obj -- start-state end-state )
    [ next-state next-state 2dup ] dip
    nfa-table get add-transition ;

: epsilon-transition ( source target -- )
    epsilon nfa-table get add-transition ;

M:: star nfa-node ( node -- start end )
    node term>> nfa-node :> ( s0 s1 )
    next-state :> s2
    next-state :> s3
    s1 s0 epsilon-transition
    s2 s0 epsilon-transition
    s2 s3 epsilon-transition
    s1 s3 epsilon-transition
    s2 s3 ;

GENERIC: modify-epsilon ( tag -- newtag )
! Potential off-by-one errors when lookaround nested in lookbehind

M: object modify-epsilon ;

: line-option ( multiline unix-lines default -- option )
    multiline option? [
        drop [ unix-lines option? ] 2dip swap ?
    ] [ 2nip ] if ;

M: $ modify-epsilon
    $unix end-of-input line-option ;

M: ^ modify-epsilon
    ^unix beginning-of-input line-option ;

M: tagged-epsilon nfa-node
    clone [ modify-epsilon ] change-tag add-simple-entry ;

M: concatenation nfa-node ( node -- start end )
    [ first>> ] [ second>> ] bi
    reversed-regexp option? [ swap ] when
    [ nfa-node ] bi@
    [ epsilon-transition ] dip ;

:: alternate-nodes ( s0 s1 s2 s3 -- start end )
    next-state :> s4
    next-state :> s5
    s4 s0 epsilon-transition
    s4 s2 epsilon-transition
    s1 s5 epsilon-transition
    s3 s5 epsilon-transition
    s4 s5 ;

M: alternation nfa-node ( node -- start end )
    [ first>> ] [ second>> ] bi
    [ nfa-node ] bi@
    alternate-nodes ;

GENERIC: modify-class ( char-class -- char-class' )

M: object modify-class ;

M: integer modify-class
    case-insensitive option? [
        dup Letter? [
            [ ch>lower ] [ ch>upper ] bi 2array <or-class>
        ] when
    ] when ;

M: integer nfa-node ( node -- start end )
    modify-class add-simple-entry ;

M: primitive-class modify-class
    class>> modify-class <primitive-class> ;

M: or-class modify-class
    seq>> [ modify-class ] map <or-class> ;

M: not-class modify-class
    class>> modify-class <not-class> ;

MEMO: unix-dot ( -- class )
    CHAR: \n <not-class> ;

MEMO: nonl-dot ( -- class )
    { CHAR: \n CHAR: \r } <or-class> <not-class> ;

M: dot modify-class
    drop dotall option? [ t ] [
        unix-lines option?
        unix-dot nonl-dot ?
    ] if ;

: modify-letter-class ( class -- newclass )
    case-insensitive option? [ drop Letter-class ] when ;
M: letter-class modify-class modify-letter-class ;
M: LETTER-class modify-class modify-letter-class ;

: cased-range? ( range -- ? )
    [ from>> ] [ to>> ] bi {
        [ [ letter? ] bi@ and ]
        [ [ LETTER? ] bi@ and ]
    } 2|| ;

M: range-class modify-class
    case-insensitive option? [
        dup cased-range? [
            [ from>> ] [ to>> ] bi
            [ [ ch>lower ] bi@ <range-class> ]
            [ [ ch>upper ] bi@ <range-class> ] 2bi 
            2array <or-class>
        ] when
    ] when ;

M: object nfa-node
    modify-class add-simple-entry ;

M: with-options nfa-node ( node -- start end )
    dup options>> [ tree>> nfa-node ] using-options ;

: construct-nfa ( ast -- nfa-table )
    [
        0 state set
        <transition-table> nfa-table set
        nfa-node
        nfa-table get
            swap dup associate >>final-states
            swap >>start-state
    ] with-scope ;
