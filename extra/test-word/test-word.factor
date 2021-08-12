! Copyright © 2021 Bruno Arias
! Hmm... this needs a better name

IN: test-word
USING: kernel sequences continuations arrays  ;

: (test-word) ( seq quot -- seq ) dupd with-datastack 2array ;
: test-word ( seq quot -- seq ) [ (test-word) ] curry map ;    

MAIN: test-word
