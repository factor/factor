! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: words

! The annotation words let you flag a word for either tracing
! or single-stepping. Note that currently, words referring to
! annotated words cannot be compiled; and annotating a word has
! no effect of compiled calls to that word.
USING: interpreter kernel lists stdio strings ;

: annotate ( word quot -- ) #! Quotation: ( word def -- def )
    over [ word-def swap call ] keep set-word-def ;

: (watch) >r "==> " swap word-name cat2 \ print r> cons cons ;

: watch ( word -- )
    #! Cause a message to be printed out when the word is
    #! executed. To undo the effect of this, reload the
    #! word with \ foo reload.
    [ (watch) ] annotate ;

: (break) [ walk ] cons ;

: break ( word -- )
    #! Cause the word to start the code walker when executed.
    [ nip (break) ] annotate ;
