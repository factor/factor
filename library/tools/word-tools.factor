! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: tools
USING: arrays definitions hashtables help tools io kernel
math namespaces prettyprint sequences strings styles words
generic ;

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

: fuzzy ( full short -- indices )
    0 swap >array [ swap pick index* [ 1+ ] keep ] map 2nip
    -1 over member? [ drop f ] when ;

: (runs) ( n i seq -- )
    2dup length < [
        3dup nth [
            number= [
                >r >r 1+ r> r>
            ] [
                split-next,
                rot drop [ nth 1+ ] 2keep
            ] if >r 1+ r>
        ] keep split, (runs)
    ] [
        3drop
    ] if ;

: runs ( seq -- seq )
    [
        split-next,
        dup first 0 rot (runs)
    ] { } make ;

: score-1 ( i full -- n )
    {
        { [ over zero? ] [ 2drop 10 ] }
        { [ 2dup length 1- = ] [ 2drop 4 ] }
        { [ 2dup >r 1- r> nth Letter? not ] [ 2drop 10 ] }
        { [ 2dup >r 1+ r> nth Letter? not ] [ 2drop 4 ] }
        { [ t ] [ 2drop 1 ] }
    } cond ;

: score ( full fuzzy -- n )
    dup [
        [ [ length ] 2apply - 15 swap [-] 3 / ] 2keep
        runs [
            [ swap score-1 ] map-with dup supremum swap length *
        ] map-with sum +
    ] [
        2drop 0
    ] if ;

: completion ( str word -- triple )
    #! triple is { score indices word }
    [
        word-name [ swap fuzzy ] keep swap [ score ] keep
    ] keep 3array ;

: completions ( str words -- seq )
    [ completion ] map-with [ first zero? not ] subset
    [ [ first ] 2apply swap - ] sort dup length 20 min head ;

: fuzzy. ( fuzzy full -- )
    dup length [
        pick member?
        [ hilite-style >r ch>string r> format ] [ write1 ] if 
    ] 2each drop ;

: completion. ( completions -- )
    first3 dup presented associate [
        dup word-vocabulary write bl word-name fuzzy.
        " (score: " swap >fixnum number>string ")" append3
        write
    ] with-nesting ;

: (apropos) ( str words -- )
    completions [ completion. terpri ] each ;

: apropos ( str -- ) all-words (apropos) ;
