! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words

! The annotation words let you flag a word for either tracing
! or single-stepping. Note that currently, words referring to
! annotated words cannot be compiled; and annotating a word has
! no effect of compiled calls to that word.
USING: interpreter kernel lists prettyprint stdio strings test ;

: annotate ( word quot -- | quot: word def -- def )
    over >r >r dup word-def r> call r> swap (define-compound) ;
    inline

: (watch) ( word def -- def )
    >r "==> " swap word-name cat2 \ print \ .s r>
    cons cons cons ;

: watch ( word -- )
    #! Cause a message to be printed out when the word is
    #! executed.
    [ (watch) ] annotate ;

: break ( word -- )
    #! Cause the word to start the code walker when executed.
    [ nip [ walk ] cons ] annotate ;

: timer ( word -- )
    #! Print the time taken to execute the word when it's called.
    [ nip [ time ] cons ] annotate ;
