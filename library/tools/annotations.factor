! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words
USING: interpreter inspector io kernel lists math namespaces
prettyprint sequences strings ;

! The annotation words let you flag a word for either tracing
! or single-stepping. Note that currently, words referring to
! annotated words cannot be compiled.
: annotate ( word quot -- | quot: word def -- def )
    over >r >r dup word-def r> call r> swap define-compound ;
    inline

: watch-msg ( word prefix -- ) write word-name print .s ;

: (watch) ( word def -- def )
    [
        swap literalize
        dup , "===> Entering: " , \ watch-msg ,
        swap %
        , "===> Leaving:  " , \ watch-msg ,
    ] [ ] make ;

: watch ( word -- )
    #! Cause a message to be printed out when the word is
    #! executed.
    [ (watch) ] annotate ;

: break ( word -- )
    #! Cause the word to start the code walker when executed.
    [ nip [ walk ] cons ] annotate ;

: +@ ( n var -- ) dup get [ swap >r + r> ] when* set ;

: with-profile ( quot word -- )
    millis >r >r call r> millis r> - swap global [ +@ ] bind ;
    inline

: profile ( word -- )
    #! When the word is called, time it, and add the time to
    #! the value in a global variable named by the word.
    [ swap [ with-profile ] curry cons ] annotate ;
