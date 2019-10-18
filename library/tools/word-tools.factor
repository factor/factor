! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: arrays definitions hashtables help tools io kernel
math namespaces prettyprint sequences strings styles words
generic completion ;

: word-outliner ( seq -- )
    natural-sort [
        [ synopsis ] keep dup [ see ] curry
        write-outliner terpri
    ] each ;

: method-usage ( word generic -- methods )
    tuck methods
    [ second flatten memq? ] subset-with
    [ first ] map
    [ swap 2array ] map-with ;

: usage. ( word -- )
    dup usage dup
    [ generic? not ] subset
    "Words calling " write pick pprint ":" print
    word-outliner
    "Methods calling " write over pprint ":" print
    [ generic? ] subset
    [ method-usage word-outliner ] each-with ;

: annotate ( word quot -- )
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

: profile ( word -- )
    [
        swap [ global [ inc ] bind ] curry swap append
    ] annotate ;

: word-completion. ( pair -- )
    first2 over summary completion>string swap write-object ;

: word-completions ( str words -- seq )
    [ word-name ] swap completions ;

: apropos ( str -- )
    all-words word-completions
    [ word-completion. terpri ] each ;
