! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors parser generic kernel classes words slots assocs
sequences arrays vectors definitions prettyprint
math hashtables sets macros namespaces ;
IN: delegate

: protocol-words ( protocol -- words )
    \ protocol-words word-prop ;

: protocol-consult ( protocol -- consulters )
    \ protocol-consult word-prop ;

GENERIC: group-words ( group -- words )

M: tuple-class group-words
    "slot-names" word-prop [
        [ reader-word ] [ writer-word ] bi
        2array [ 0 2array ] map
    ] map concat ;

! Consultation

: consult-method ( word class quot -- )
    [ drop swap first create-method ]
    [
        nip
        [
            over second saver %
            %
            dup second restorer %
            first ,
        ] [ ] make
    ] 3bi
    define ;

: change-word-prop ( word prop quot -- )
    rot props>> swap change-at ; inline

: register-protocol ( group class quot -- )
    rot \ protocol-consult [ swapd ?set-at ] change-word-prop ;

: define-consult ( group class quot -- )
    [ register-protocol ]
    [ rot group-words -rot [ consult-method ] 2curry each ]
    3bi ;

: CONSULT:
    scan-word scan-word parse-definition define-consult ; parsing

! Protocols

: cross-2each ( seq1 seq2 quot -- )
    [ with each ] 2curry each ; inline

: forget-all-methods ( classes words -- )
    [ first method forget ] cross-2each ;

: protocol-users ( protocol -- users )
    protocol-consult keys ;

: lost-words ( protocol wordlist -- lost-words )
    >r protocol-words r> diff ;

: forget-old-definitions ( protocol new-wordlist -- )
    [ drop protocol-users ] [ lost-words ] 2bi
    forget-all-methods ;

: added-words ( protocol wordlist -- added-words )
    swap protocol-words diff ;

: add-new-definitions ( protocol wordlist -- )
    [ drop protocol-consult >alist ] [ added-words ] 2bi
    [ swap first2 consult-method ] cross-2each ;

: initialize-protocol-props ( protocol wordlist -- )
    [
        drop \ protocol-consult
        [ H{ } assoc-like ] change-word-prop
    ] [ { } like \ protocol-words set-word-prop ] 2bi ;

: fill-in-depth ( wordlist -- wordlist' )
    [ dup word? [ 0 2array ] when ] map ;

: define-protocol ( protocol wordlist -- )
    fill-in-depth
    [ forget-old-definitions ]
    [ add-new-definitions ]
    [ initialize-protocol-props ] 2tri ;

: PROTOCOL:
    CREATE-WORD
    [ define-symbol ]
    [ f "inline" set-word-prop ]
    [ parse-definition define-protocol ] tri ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ f forget-old-definitions ] [ call-next-method ] bi ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol synopsis* word-synopsis ; ! Necessary?

M: protocol group-words protocol-words ;
