! Copyright © 2021 Bruno Arias
! Hmm... this needs a better name

IN: test-word
USING: kernel sequences continuations arrays  ;

: (gather-results) ( seq quot -- seq ) dupd with-datastack 2array ;
: gather-results ( seq quot -- seq ) [ (gather-results) ] curry map ;    

: (get-row) ( stack quot -- stack seq ) [ with-datastack ] 2keep first 2array;
: gather-intermediates ( stack quot -- stack seq ) [ 1quotation (get-row) ] map ;

MAIN: gather-results
