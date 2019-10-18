! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays definitions graphs hashtables help io kernel math
namespaces porter-stemmer prettyprint sequences strings words ;

! Right now this code is specific to the help. It will be
! generalized to an abstract full text search engine later.

: ignored-word? ( string -- ? )
    { "the" "of" "is" "to" "an" "and" "if" "in" "with" "this" "not" "are" "for" "by" "can" "be" "or" "from" "it" "does" "as" } member? ;

: tokenize ( string -- seq )
    [ dup letter? swap LETTER? or not ] split*
    [ >lower stem ] map
    [
        dup ignored-word? over length 1 = or swap empty? or not
    ] subset ;

: index-text ( topic string -- )
    tokenize [ 1 -rot nest hash+ ] each-with ;

SYMBOL: term-index

: index-article ( topic -- )
    term-index get [
        [ dup [ help ] string-out index-text ] bind
    ] [
        drop
    ] if* ;

: unindex-article ( article -- )
    term-index get [
        [ nip remove-hash ] hash-each-with
    ] [
        drop
    ] if* ;

: discard-irrelevant ( results -- newresults )
    #! Discard results in the low 33%
    dup 0 [ second max ] reduce
    swap [ first2 rot / 2array ] map-with
    [ second 1/3 > ] subset ;

: count-occurrences ( seq -- hash )
    [
        dup [ [ drop off ] hash-each ] each
        [ [ swap +@ ] hash-each ] each
    ] make-hash ;

: search-help ( phrase -- assoc )
    tokenize [ term-index get hash ] map [ ] subset
    count-occurrences hash>alist
    [ first2 2array ] map
    [ [ second ] 2apply swap - ] sort discard-irrelevant ;

: index-help ( -- )
    term-index get [
        dup clear-hash
        [ all-articles [ index-article ] each ] bind
    ] when* ;

: remove-article ( name -- )
    dup articles get hash-member? [
        dup unxref-article
        dup unindex-article
        dup articles get remove-hash
    ] when drop ;

: add-article ( name article -- )
    over remove-article
    over >r swap articles get set-hash r>
    dup xref-article index-article ;

: remove-word-help ( word -- )
    dup word-help [
        dup unxref-article
        dup unindex-article
    ] when drop ;

: set-word-help ( word content -- )
    over remove-word-help
    over >r "help" set-word-prop r>
    dup xref-article index-article ;

: search-help. ( phrase -- )
    search-help [ first ] map help-outliner ;

! Definition protocol
M: link forget link-name remove-article ;

M: word-link forget f "help" set-word-prop ;
