! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors hashtables kernel math vectors ;
IN: regexp.backend

TUPLE: regexp
    raw
    { options hashtable }
    stack
    parse-tree
    nfa-table
    dfa-table
    minimized-table
    matchers
    { nfa-traversal-flags hashtable }
    { dfa-traversal-flags hashtable }
    { state integer }
    { new-states vector }
    { visited-states hashtable } ;

: reset-regexp ( regexp -- regexp )
    0 >>state
    V{ } clone >>stack
    V{ } clone >>new-states
    H{ } clone >>visited-states ;

SYMBOL: current-regexp
