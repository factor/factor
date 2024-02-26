! Copyright (C) 2008, 2009 Doug Coleman, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators.short-circuit kernel
math namespaces regexp.ast regexp.classes
regexp.transition-tables sequences sets unicode vectors ;
IN: regexp.nfa

! This uses unicode for ch>upper and ch>lower but
! case-insensitive matching should be done by case-folding
! everything before processing starts

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

DEFER: modify-class

! Potential off-by-one errors when lookaround nested in lookbehind

M: tagged-epsilon nfa-node
    clone [ modify-class ] change-tag add-simple-entry ;

M: concatenation nfa-node
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

M: alternation nfa-node
    [ first>> ] [ second>> ] bi
    [ nfa-node ] bi@
    alternate-nodes ;

GENERIC: modify-class ( char-class -- char-class' )

M: object modify-class ;

M: concatenation modify-class
    [ first>> ] [ second>> ] bi [ modify-class ] bi@
    concatenation boa ;

M: alternation modify-class
    [ first>> ] [ second>> ] bi [ modify-class ] bi@
    alternation boa ;

M: lookahead modify-class
    term>> modify-class lookahead boa ;

M: lookbehind modify-class
    term>> modify-class lookbehind boa ;

: line-option ( multiline unix-lines default -- option )
    multiline option? [
        drop [ unix-lines option? ] 2dip swap ?
    ] [ 2nip ] if ;

M: $crlf modify-class
    $unix end-of-input line-option ;

M: ^crlf modify-class
    ^unix beginning-of-input line-option ;

M: integer modify-class
    case-insensitive option? [
        dup Letter? [
            [ ch>lower ] [ ch>upper ] bi 2array <or-class>
        ] when
    ] when ;

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
        [ [ letter? ] both? ]
        [ [ LETTER? ] both? ]
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

M: with-options nfa-node
    dup options>> [ tree>> nfa-node ] using-options ;

: construct-nfa ( ast -- nfa-table )
    [
        0 state namespaces:set
        <transition-table> nfa-table namespaces:set
        nfa-node
        nfa-table get
            swap 1array fast-set >>final-states
            swap >>start-state
    ] with-scope ;
