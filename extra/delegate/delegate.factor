! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: parser generic kernel classes words slots assocs sequences arrays
vectors definitions prettyprint combinators.lib math sets ;
IN: delegate

! Protocols

: cross-2each ( seq1 seq2 quot -- )
    [ with each ] 2curry each ; inline

: forget-all-methods ( classes words -- )
    [ 2array forget ] cross-2each ;

: protocol-words ( protocol -- words )
    "protocol-words" word-prop ;

: protocol-users ( protocol -- users )
    "protocol-users" word-prop ;

: users-and-words ( protocol -- users words )
    [ protocol-users ] [ protocol-words ] bi ;

: forget-old-definitions ( protocol new-wordlist -- )
    >r users-and-words r>
    diff forget-all-methods ;

: define-protocol ( protocol wordlist -- )
    ! 2dup forget-old-definitions
    { } like "protocol-words" set-word-prop ;

: fill-in-depth ( wordlist -- wordlist' )
    [ dup word? [ 0 2array ] when ] map ;

: PROTOCOL:
    CREATE-WORD
    dup define-symbol
    dup f "inline" set-word-prop
    parse-definition fill-in-depth define-protocol ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ users-and-words forget-all-methods ] [ call-next-method ] bi ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol synopsis* word-synopsis ; ! Necessary?

GENERIC: group-words ( group -- words )

M: protocol group-words
    "protocol-words" word-prop ;

M: tuple-class group-words
    "slot-names" word-prop [
        [ reader-word ] [ writer-word ] bi
        2array [ 0 2array ] map
    ] map concat ;

! Consultation

: define-consult-method ( word class quot -- )
    [ drop swap first create-method ]
    [ nip swap first2 swapd [ ndip ] 2curry swap suffix ] 3bi define ;

: change-word-prop ( word prop quot -- )
    >r swap word-props r> change-at ; inline

: add ( item vector/f -- vector )
    2dup member? [ nip ] [ ?push ] if ;

: use-protocol ( class group -- )
    "protocol-users" [ add ] change-word-prop ;

: define-consult ( group class quot -- )
    swapd >r 2dup use-protocol group-words swap r>
    [ define-consult-method ] 2curry each ;

: CONSULT:
    scan-word scan-word parse-definition define-consult ; parsing

! Mimic still needs to be updated

: mimic-method ( mimicker mimicked generic -- )
    tuck method 
    [ [ create-method-in ] [ word-def ] bi* define ]
    [ 2drop ] if* ;

: define-mimic ( group mimicker mimicked -- )
    [ drop swap use-protocol ] [
        rot group-words -rot
        [ rot first mimic-method ] 2curry each
    ] 3bi ;

: MIMIC:
    scan-word scan-word scan-word define-mimic ; parsing
