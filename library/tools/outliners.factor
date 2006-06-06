! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: inspector
USING: arrays help io kernel math namespaces prettyprint
sequences words ;

: word-outliner ( seq quot -- )
    swap natural-sort [
        [ synopsis ] keep rot dupd curry
        simple-outliner terpri
    ] each-with ;

: usage. ( word -- ) usage [ usage. ] word-outliner ;

: uses. ( word -- ) uses [ uses. ] word-outliner ;

: apropos ( substring -- )
    all-words completions natural-sort [ help ] word-outliner ;
