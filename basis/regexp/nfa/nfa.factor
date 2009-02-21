! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel
locals math namespaces sequences fry quotations
math.order math.ranges vectors unicode.categories
regexp.transition-tables words sets hashtables combinators.short-circuit
unicode.case.private regexp.ast regexp.classes ;
IN: regexp.nfa

! This uses unicode.case.private for ch>upper and ch>lower
! but case-insensitive matching should be done by case-folding everything
! before processing starts

GENERIC: remove-lookahead ( syntax-tree -- syntax-tree' )
! This is unfinished and does nothing right now!

M: object remove-lookahead ;

M: with-options remove-lookahead
    [ tree>> remove-lookahead ] [ options>> ] bi <with-options> ;

M: alternation remove-lookahead
    [ first>> ] [ second>> ] bi [ remove-lookahead ] bi@ alternation boa ;

M: concatenation remove-lookahead ;

SINGLETON: eps

SYMBOL: option-stack

SYMBOL: state

: next-state ( -- state )
    state [ get ] [ inc ] bi ;

SYMBOL: nfa-table
: table ( -- table ) nfa-table get ;

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

: add-simple-entry ( obj class -- start-state end-state )
    [ next-state next-state 2dup ] 2dip
    make-transition table add-transition ;

: epsilon-transition ( source target -- )
    eps <literal-transition> table add-transition ;

M:: star nfa-node ( node -- start end )
    node term>> nfa-node :> s1 :> s0
    next-state :> s2
    next-state :> s3
    s1 s0 epsilon-transition
    s2 s0 epsilon-transition
    s2 s3 epsilon-transition
    s1 s3 epsilon-transition
    s2 s3 ;

M: epsilon nfa-node
    drop eps literal-transition add-simple-entry ;

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
    modify-class dup class?
    class-transition literal-transition ?
    add-simple-entry ;

M: primitive-class modify-class
    class>> modify-class <primitive-class> ;

M: or-class modify-class
    seq>> [ modify-class ] map <or-class> ;

M: not-class modify-class
    class>> modify-class <not-class> ;

M: any-char modify-class
    [ dotall option? ] dip any-char-no-nl ? ;

: modify-letter-class ( class -- newclass )
    case-insensitive option? [ drop Letter-class ] when ;
M: letter-class modify-class modify-letter-class ;
M: LETTER-class modify-class modify-letter-class ;

: cased-range? ( range -- ? )
    [ from>> ] [ to>> ] bi {
        [ [ letter? ] bi@ and ]
        [ [ LETTER? ] bi@ and ]
    } 2|| ;

M: range modify-class
    case-insensitive option? [
        dup cased-range? [
            [ from>> ] [ to>> ] bi
            [ [ ch>lower ] bi@ <range> ]
            [ [ ch>upper ] bi@ <range> ] 2bi 
            2array <or-class>
        ] when
    ] when ;

M: class nfa-node
    modify-class class-transition add-simple-entry ;

M: with-options nfa-node ( node -- start end )
    dup options>> [ tree>> nfa-node ] using-options ;

: construct-nfa ( ast -- nfa-table )
    [
        0 state set
        <transition-table> nfa-table set
        remove-lookahead nfa-node
        table
            swap dup associate >>final-states
            swap >>start-state
    ] with-scope ;
