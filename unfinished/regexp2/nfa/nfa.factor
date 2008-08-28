! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs grouping kernel regexp2.backend
locals math namespaces regexp2.parser sequences state-tables fry
quotations math.order math.ranges vectors unicode.categories
regexp2.utils regexp2.transition-tables words sequences.lib sets ;
IN: regexp2.nfa

SYMBOL: negation-mode
: negated? ( -- ? ) negation-mode get 0 or odd? ; 

SINGLETON: eps

MIXIN: traversal-flag
SINGLETON: lookahead-on INSTANCE: lookahead-on traversal-flag
SINGLETON: lookahead-off INSTANCE: lookahead-off traversal-flag
SINGLETON: capture-group-on INSTANCE: capture-group-on traversal-flag
SINGLETON: capture-group-off INSTANCE: capture-group-off traversal-flag

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
        negated? [
            s0 f obj class make-transition table add-transition
            s0 s1 <default-transition> table add-transition
        ] [
            s0 s1 obj class make-transition table add-transition
        ] if
        s0 s1 2array stack push
        t s1 table final-states>> set-at ] ;

: add-traversal-flag ( flag -- )
    stack peek second
    current-regexp get traversal-flags>> push-at ;

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

M: kleene-star nfa-node ( node -- )
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
    [ [ nfa-node ] each ]
    [ length 1- [ concatenate-nodes ] times ] bi ;

M: alternation nfa-node ( node -- )
    seq>>
    [ [ nfa-node ] each ]
    [ length 1- [ alternate-nodes ] times ] bi ;

M: constant nfa-node ( node -- )
    char>> literal-transition add-simple-entry ;

M: epsilon nfa-node ( node -- )
    drop eps literal-transition add-simple-entry ;

M: word nfa-node ( node -- )
    class-transition add-simple-entry ;

M: character-class-range nfa-node ( node -- )
    class-transition add-simple-entry ;

M: capture-group nfa-node ( node -- )
    term>> nfa-node ;

M: negation nfa-node ( node -- )
    negation-mode inc
    term>> nfa-node 
    negation-mode dec ;

M: lookahead nfa-node ( node -- )
    eps literal-transition add-simple-entry
    lookahead-on add-traversal-flag
    term>> nfa-node
    eps literal-transition add-simple-entry
    lookahead-off add-traversal-flag
    2 [ concatenate-nodes ] times ;

: construct-nfa ( regexp -- )
    [
        reset-regexp
        negation-mode off
        [ current-regexp set ]
        [ parse-tree>> nfa-node ]
        [ set-start-state ] tri
    ] with-scope ;
