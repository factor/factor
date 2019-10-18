! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: words
USING: help inspector io kernel math namespaces prettyprint
sequences strings walker ;

: word-outliner ( word quot -- )
    swap natural-sort [
        dup rot curry >r [ synopsis ] keep r>
        write-outliner terpri
    ] each-with ;

: usage. ( word -- )
    usage [ usage. ] word-outliner ;

: apropos ( substring -- )
    all-words completions [ (help) ] word-outliner ;

: annotate ( word quot -- | quot: word def -- def )
    over >r >r dup word-def r> call r> swap define-compound ;
    inline

: watch-msg ( word prefix -- ) write word-name print .s flush ;

: (watch) ( word def -- def )
    [
        swap literalize
        dup , "===> Entering: " , \ watch-msg ,
        swap %
        , "===> Leaving:  " , \ watch-msg ,
    ] [ ] make ;

: watch ( word -- ) [ (watch) ] annotate ;

: break ( word -- ) [ nip [ walk ] curry ] annotate ;

: break-on ( word test -- | test: -- ? )
    swap [
        nip [ swap % dup [ walk ] curry , , \ if , ] [ ] make
    ] annotate ;

: profile ( word -- )
    [ swap [ global [ inc ] bind ] curry swap append ] annotate ;
