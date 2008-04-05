! Copyright (C) 2007 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: parser generic kernel classes words slots assocs sequences arrays
vectors definitions prettyprint ;
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
    seq-diff forget-all-methods ;

: define-protocol ( protocol wordlist -- )
    2dup forget-old-definitions
    { } like "protocol-words" set-word-prop ;

: PROTOCOL:
    CREATE-WORD
    dup define-symbol
    dup f "inline" set-word-prop
    parse-definition define-protocol ; parsing

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ users-and-words forget-all-methods ] [ call-next-method ] bi ;

M: protocol definition protocol-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol synopsis* word-synopsis ; ! Necessary?

GENERIC: group-words ( group -- words )

M: protocol group-words
    "protocol-words" word-prop ;

M: generic group-words
   1array ;

M: tuple-class group-words
    "slots" word-prop
    [ [ slot-spec-reader ] map ]
    [ [ slot-spec-writer ] map ] bi append ;

! Consultation

: define-consult-method ( word class quot -- )
    pick suffix >r swap create-method r> define ;

: change-word-prop ( word prop quot -- )
    >r swap word-props r> change-at ; inline

: add ( item vector/f -- vector )
    2dup member? [ nip ] [ ?push ] if ;

: declare-consult ( class group -- )
    "protocol-users" [ add ] change-word-prop ;

: define-consult ( class group quot -- )
    >r 2dup declare-consult group-words swap r>
    [ define-consult-method ] 2curry each ;

: CONSULT:
    scan-word scan-word parse-definition swapd define-consult ; parsing

! Mimic still needs to be updated

: define-mimic ( group mimicker mimicked -- )
    rot group-words -rot [
        pick "methods" word-prop at dup
        [ >r swap create-method-in r> word-def define ]
        [ 3drop ] if
    ] 2curry each ; 

: MIMIC:
    scan-word scan-word scan-word define-mimic ; parsing
