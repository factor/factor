! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel
locals math namespaces sequences fry quotations
math.order math.ranges vectors unicode.categories
regexp.transition-tables words sets 
unicode.case.private regexp.ast regexp.classes ;
! This uses unicode.case.private for ch>upper and ch>lower
! but case-insensitive matching should be done by case-folding everything
! before processing starts
IN: regexp.nfa

ERROR: feature-is-broken feature ;

SYMBOL: negated?

: negate ( -- )
    negated? [ not ] change ;

SINGLETON: eps

SYMBOL: option-stack

SYMBOL: combine-stack

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

: set-start-state ( -- nfa-table )
    nfa-table get
        combine-stack get pop first >>start-state ;

GENERIC: nfa-node ( node -- )

:: add-simple-entry ( obj class -- )
    [let* | s0 [ next-state ]
            s1 [ next-state ]
            stack [ combine-stack get ]
            table [ nfa-table get ] |
        negated? get [
            s0 f obj class make-transition table add-transition
            s0 s1 <default-transition> table add-transition
        ] [
            s0 s1 obj class make-transition table add-transition
        ] if
        s0 s1 2array stack push
        t s1 table final-states>> set-at ] ;

:: concatenate-nodes ( -- )
    [let* | stack [ combine-stack get ]
            table [ nfa-table get ]
            s2 [ stack peek first ]
            s3 [ stack pop second ]
            s0 [ stack peek first ]
            s1 [ stack pop second ] |
        s1 s2 eps <literal-transition> table add-transition
        s1 table final-states>> delete-at
        s0 s3 2array stack push ] ;

:: alternate-nodes ( -- )
    [let* | stack [ combine-stack get ]
            table [ nfa-table get ]
            s2 [ stack peek first ]
            s3 [ stack pop second ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            s4 [ next-state ]
            s5 [ next-state ] |
        s4 s0 eps <literal-transition> table add-transition
        s4 s2 eps <literal-transition> table add-transition
        s1 s5 eps <literal-transition> table add-transition
        s3 s5 eps <literal-transition> table add-transition
        s1 table final-states>> delete-at
        s3 table final-states>> delete-at
        t s5 table final-states>> set-at
        s4 s5 2array stack push ] ;

M: star nfa-node ( node -- )
    term>> nfa-node
    [let* | stack [ combine-stack get ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            s2 [ next-state ]
            s3 [ next-state ]
            table [ nfa-table get ] |
        s1 table final-states>> delete-at
        t s3 table final-states>> set-at
        s1 s0 eps <literal-transition> table add-transition
        s2 s0 eps <literal-transition> table add-transition
        s2 s3 eps <literal-transition> table add-transition
        s1 s3 eps <literal-transition> table add-transition
        s2 s3 2array stack push ] ;

M: concatenation nfa-node ( node -- )
    seq>> [ eps literal-transition add-simple-entry ] [
        reversed-regexp option? [ <reversed> ] when
        [ [ nfa-node ] each ]
        [ length 1- [ concatenate-nodes ] times ] bi
    ] if-empty ;

M: alternation nfa-node ( node -- )
    seq>>
    [ [ nfa-node ] each ]
    [ length 1- [ alternate-nodes ] times ] bi ;

M: integer nfa-node ( node -- )
    case-insensitive option? [
        dup [ ch>lower ] [ ch>upper ] bi
        2dup = [
            2drop
            literal-transition add-simple-entry
        ] [
            [ literal-transition add-simple-entry ] bi@
            alternate-nodes drop
        ] if
    ] [
        literal-transition add-simple-entry
    ] if ;

M: primitive-class nfa-node ( node -- )
    class>> dup
    { letter-class LETTER-class } member? case-insensitive option? and
    [ drop Letter-class ] when
    class-transition add-simple-entry ;

M: any-char nfa-node ( node -- )
    [ dotall option? ] dip any-char-no-nl ?
    class-transition add-simple-entry ;

M: negation nfa-node ( node -- )
    negate term>> nfa-node negate ;

M: range nfa-node ( node -- )
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

M: with-options nfa-node ( node -- )
    dup options>> [ tree>> nfa-node ] using-options ;

: construct-nfa ( ast -- nfa-table )
    [
        negated? off
        V{ } clone combine-stack set
        0 state set
        <transition-table> clone nfa-table set
        nfa-node
        set-start-state
    ] with-scope ;
