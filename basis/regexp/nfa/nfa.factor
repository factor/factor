! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel regexp.backend
locals math namespaces regexp.parser sequences fry quotations
math.order math.ranges vectors unicode.categories regexp.utils
regexp.transition-tables words sets regexp.classes unicode.case.private ;
! This uses unicode.case.private for ch>upper and ch>lower
! but case-insensitive matching should be done by case-folding everything
! before processing starts
IN: regexp.nfa

ERROR: feature-is-broken feature ;

SYMBOL: negated?

SINGLETON: eps

: options ( -- obj ) current-regexp get options>> ;

: option? ( obj -- ? ) options key? ;

: option-on ( obj -- ) options conjoin ;

: option-off ( obj -- ) options delete-at ;

: next-state ( regexp -- state )
    [ state>> ] [ [ 1+ ] change-state drop ] bi ;

: set-start-state ( regexp -- )
    dup stack>> [
        drop
    ] [
        [ nfa-table>> ] [ pop first ] bi* >>start-state drop
    ] if-empty ;

GENERIC: nfa-node ( node -- )

:: add-simple-entry ( obj class -- )
    [let* | regexp [ current-regexp get ]
            s0 [ regexp next-state ]
            s1 [ regexp next-state ]
            stack [ regexp stack>> ]
            table [ regexp nfa-table>> ] |
        negated? get [
            s0 f obj class make-transition table add-transition
            s0 s1 <default-transition> table add-transition
        ] [
            s0 s1 obj class make-transition table add-transition
        ] if
        s0 s1 2array stack push
        t s1 table final-states>> set-at ] ;

:: concatenate-nodes ( -- )
    [let* | regexp [ current-regexp get ]
            stack [ regexp stack>> ]
            table [ regexp nfa-table>> ]
            s2 [ stack peek first ]
            s3 [ stack pop second ]
            s0 [ stack peek first ]
            s1 [ stack pop second ] |
        s1 s2 eps <literal-transition> table add-transition
        s1 table final-states>> delete-at
        s0 s3 2array stack push ] ;

:: alternate-nodes ( -- )
    [let* | regexp [ current-regexp get ]
            stack [ regexp stack>> ]
            table [ regexp nfa-table>> ]
            s2 [ stack peek first ]
            s3 [ stack pop second ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            s4 [ regexp next-state ]
            s5 [ regexp next-state ] |
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
    [let* | regexp [ current-regexp get ]
            stack [ regexp stack>> ]
            s0 [ stack peek first ]
            s1 [ stack pop second ]
            s2 [ regexp next-state ]
            s3 [ regexp next-state ]
            table [ regexp nfa-table>> ] |
        s1 table final-states>> delete-at
        t s3 table final-states>> set-at
        s1 s0 eps <literal-transition> table add-transition
        s2 s0 eps <literal-transition> table add-transition
        s2 s3 eps <literal-transition> table add-transition
        s1 s3 eps <literal-transition> table add-transition
        s2 s3 2array stack push ] ;

M: concatenation nfa-node ( node -- )
    seq>>
    reversed-regexp option? [ <reversed> ] when
    [ [ nfa-node ] each ]
    [ length 1- [ concatenate-nodes ] times ] bi ;

M: alternation nfa-node ( node -- )
    seq>>
    [ [ nfa-node ] each ]
    [ length 1- [ alternate-nodes ] times ] bi ;

M: constant nfa-node ( node -- )
    case-insensitive option? [
        dup char>> [ ch>lower ] [ ch>upper ] bi
        2dup = [
            2drop
            char>> literal-transition add-simple-entry
        ] [
            [ literal-transition add-simple-entry ] bi@
            alternate-nodes drop
        ] if
    ] [
        char>> literal-transition add-simple-entry
    ] if ;

M: word nfa-node ( node -- ) class-transition add-simple-entry ;

M: any-char nfa-node ( node -- )
    [ dotall option? ] dip any-char-no-nl ?
    class-transition add-simple-entry ;

M: beginning-of-line nfa-node ( node -- ) class-transition add-simple-entry ;

M: end-of-line nfa-node ( node -- ) class-transition add-simple-entry ;

: choose-letter-class ( node -- node' )
    case-insensitive option? Letter-class rot ? ;

M: letter-class nfa-node ( node -- )
    choose-letter-class class-transition add-simple-entry ;

M: LETTER-class nfa-node ( node -- )
    choose-letter-class class-transition add-simple-entry ;

M: character-class-range nfa-node ( node -- )
    case-insensitive option? [
        ! This should be implemented for Unicode by case-folding
        ! the input and all strings in the regexp.
        dup [ from>> ] [ to>> ] bi
        2dup [ Letter? ] bi@ and [
            rot drop
            [ [ ch>lower ] bi@ character-class-range boa ]
            [ [ ch>upper ] bi@ character-class-range boa ] 2bi 
            [ class-transition add-simple-entry ] bi@
            alternate-nodes
        ] [
            2drop
            class-transition add-simple-entry
        ] if
    ] [
        class-transition add-simple-entry
    ] if ;

M: option nfa-node ( node -- )
    [ option>> ] [ on?>> ] bi [ option-on ] [ option-off ] if
    eps literal-transition add-simple-entry ;

: construct-nfa ( regexp -- )
    [
        reset-regexp
        [ current-regexp set ]
        [ parse-tree>> nfa-node ]
        [ set-start-state ] tri
    ] with-scope ;
