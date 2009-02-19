! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel
locals math namespaces sequences fry quotations
math.order math.ranges vectors unicode.categories
regexp.transition-tables words sets hashtables
unicode.case.private regexp.ast regexp.classes ;
! This uses unicode.case.private for ch>upper and ch>lower
! but case-insensitive matching should be done by case-folding everything
! before processing starts
IN: regexp.nfa

SYMBOL: negated?

: negate ( -- )
    negated? [ not ] change ;

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

:: add-simple-entry ( obj class -- start-state end-state )
    next-state :> s0
    next-state :> s1
    negated? get [
        s0 f obj class make-transition table add-transition
        s0 s1 <default-transition> table add-transition
    ] [
        s0 s1 obj class make-transition table add-transition
    ] if
    s0 s1 ;

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

M: integer nfa-node ( node -- start end )
    case-insensitive option? [
        dup [ ch>lower ] [ ch>upper ] bi
        2dup = [
            2drop
            literal-transition add-simple-entry
        ] [
            [ literal-transition add-simple-entry ] bi@
            alternate-nodes [ nip ] dip
        ] if
    ] [
        literal-transition add-simple-entry
    ] if ;

M: primitive-class nfa-node ( node -- start end )
    class>> dup
    { letter-class LETTER-class } member? case-insensitive option? and
    [ drop Letter-class ] when
    class-transition add-simple-entry ;

M: any-char nfa-node ( node -- start end )
    [ dotall option? ] dip any-char-no-nl ?
    class-transition add-simple-entry ;

M: negation nfa-node ( node -- start end )
    negate term>> nfa-node negate ;

M: range nfa-node ( node -- start end )
    case-insensitive option? [
        ! This should be implemented for Unicode by case-folding
        ! the input and all strings in the regexp.
        dup [ from>> ] [ to>> ] bi
        2dup [ Letter? ] bi@ and [
            rot drop
            [ [ ch>lower ] bi@ <range> ]
            [ [ ch>upper ] bi@ <range> ] 2bi 
            [ class-transition add-simple-entry ] bi@
            alternate-nodes
        ] [
            2drop
            class-transition add-simple-entry
        ] if
    ] [
        class-transition add-simple-entry
    ] if ;

M: with-options nfa-node ( node -- start end )
    dup options>> [ tree>> nfa-node ] using-options ;

: construct-nfa ( ast -- nfa-table )
    [
        negated? off
        0 state set
        <transition-table> clone nfa-table set
        nfa-node
        table
            swap dup associate >>final-states
            swap >>start-state
    ] with-scope ;
