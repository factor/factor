! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: help
USING: arrays graphs hashtables help io kernel math namespaces
porter-stemmer prettyprint sequences strings ;

: ignored-word? ( str -- ? )
    { "the" "of" "is" "to" "an" "and" "if" "in" "with" "this" "not" "are" "for" "by" "can" "be" "or" "from" "it" "does" "as" } member? ;

: tokenize ( string -- seq )
    [ dup letter? swap LETTER? or not ] split*
    [ >lower stem ] map
    [
        dup ignored-word? over length 1 = or swap empty? or not
    ] subset ;

: count-occurrences ( seq -- hash )
    [
        dup [ hash-keys [ off ] each ] each
        [ [ drop inc ] hash-each ] each
    ] make-hash ;

: search-index ( phrase index -- assoc )
    swap tokenize [ swap hash ] map-with [ ] subset
    count-occurrences hash>alist
    [ first2 dup zero? [ 1- 10 * 1+ ] unless 2array ] map
    [ [ second ] 2apply swap - ] sort ;

SYMBOL: help-index

: index-help
    H{ } clone help-index set
    all-articles
    [ [ help ] string-out tokenize ]
    help-index get build-graph ;

: search-help ( phrase -- assoc )
    help-index get search-index ;

: search-help. ( phrase -- )
    search-help H{ } [ pprint ] tabular-output ;
