! Copyright © 2021 Bruno Arias
! Hmm... this needs a better name

IN: test-word
USING: kernel sequences continuations arrays  ;

: (test-word) ( seq quot -- seq ) dupd with-datastack 2array ;
: test-word ( seq quot -- seq ) [ (test-word) ] curry map ;    

: (get-row) ( stack quot -- stack seq ) [ with-datastack ] 2keep first 2array;
: before-after ( stack quot -- stack seq ) [ 1quotation (get-row) ] map ;

MAIN: test-word
