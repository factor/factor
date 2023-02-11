! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs classes classes.tuple.private combinators
effects.parser generic.parser kernel math math.order parser
quotations sequences sorting words ;
IN: pair-methods

ERROR: no-pair-method a b generic ;

: ?swap ( a b ? -- a/b b/a )
    [ swap ] when ;

: method-sort-key ( pair -- key )
    first2 [ tuple-layout third ] bi@ + ;

: pair-match-condition ( pair -- quot )
    first2 [ [ instance? ] swap prefix ] bi@ [ ] 2sequence
    [ 2dup ] [ bi* and ] surround ;

: pair-method-cond ( pair quot -- array )
    [ pair-match-condition ] [ ] bi* 2array ;

: sorted-pair-methods ( word -- alist )
    "pair-generic-methods" word-prop >alist
    [ first method-sort-key ] inv-sort-by ;

: pair-generic-definition ( word -- def )
    [ sorted-pair-methods [ first2 pair-method-cond ] map ]
    [ [ no-pair-method ] curry suffix ] bi 1quotation
    [ 2dup [ class-of ] compare +gt+ eq? ?swap ] [ cond ] surround ;

: make-pair-generic ( word -- )
    dup pair-generic-definition define ;

: define-pair-generic ( word effect -- )
    [ set-stack-effect ]
    [ drop H{ } clone "pair-generic-methods" set-word-prop ]
    [ drop make-pair-generic ] 2tri ;

: (PAIR-GENERIC:) ( -- )
    scan-new-generic scan-effect define-pair-generic ;

SYNTAX: PAIR-GENERIC: (PAIR-GENERIC:) ;

: define-pair-method ( a b pair-generic definition -- )
    [ 2array ] 2dip swap
    [ "pair-generic-methods" word-prop swapd set-at ]
    [ make-pair-generic ] bi ;

: ?prefix-swap ( quot ? -- quot' )
    [ \ swap prefix ] when ;

: (PAIR-M:) ( -- )
    scan-word scan-word 2dup <=> +gt+ eq? [
        ?swap scan-word parse-definition
    ] keep ?prefix-swap define-pair-method ;

SYNTAX: PAIR-M: (PAIR-M:) ;
