! Copyright (C) 2007, 2008 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.tuple definitions
generalizations generic hashtables kernel lexer make math parser
sequences sets slots words words.symbol fry ;
IN: delegate

: protocol-words ( protocol -- words )
    \ protocol-words word-prop ;

: protocol-consult ( protocol -- consulters )
    \ protocol-consult word-prop ;

GENERIC: group-words ( group -- words )

M: tuple-class group-words
    all-slots [
        name>>
        [ reader-word 0 2array ]
        [ writer-word 0 2array ] bi
        2array
    ] map concat ;

! Consultation

: consult-method ( word class quot -- )
    [ drop swap first create-method ]
    [ nip [ , dup second , \ ndip , first , ] [ ] make ] 3bi
    define ;

: change-word-prop ( word prop quot -- )
    [ swap props>> ] dip change-at ; inline

: register-protocol ( group class quot -- )
    [ \ protocol-consult ] 2dip
    '[ [ _ _ swap ] dip ?set-at ] change-word-prop ;

: define-consult ( group class quot -- )
    [ register-protocol ]
    [ [ group-words ] 2dip '[ _ _ consult-method ] each ]
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
    [ protocol-words ] dip diff ;

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
    [ drop define-symbol ] [
        fill-in-depth
        [ forget-old-definitions ]
        [ add-new-definitions ]
        [ initialize-protocol-props ] 2tri
    ] 2bi ;

: PROTOCOL:
    CREATE-WORD parse-definition define-protocol ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ f forget-old-definitions ] [ call-next-method ] bi ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol group-words protocol-words ;

: SLOT-PROTOCOL:
    CREATE-WORD ";" parse-tokens
    [ [ reader-word ] [ writer-word ] bi 2array ] map concat
    define-protocol ; parsing