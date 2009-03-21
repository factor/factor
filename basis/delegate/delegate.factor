! Copyright (C) 2007, 2008 Daniel Ehrenberg
! Portions copyright (C) 2009 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.tuple definitions generic
generic.standard hashtables kernel lexer math parser
generic.parser sequences sets slots words words.symbol fry
compiler.units ;
IN: delegate

<PRIVATE

: protocol-words ( protocol -- words )
    \ protocol-words word-prop ;

: protocol-consult ( protocol -- consulters )
    \ protocol-consult word-prop ;

GENERIC: group-words ( group -- words )

M: standard-generic group-words
    dup "combination" word-prop #>> 2array 1array ;

M: tuple-class group-words
    all-slots [
        name>>
        [ reader-word 0 2array ]
        [ writer-word 0 2array ] bi
        2array
    ] map concat ;

! Consultation

TUPLE: consultation group class quot loc ;

: <consultation> ( group class quot -- consultation )
    f consultation boa ; 

: create-consult-method ( word consultation -- method )
    [ class>> swap first create-method dup fake-definition ] keep
    [ drop ] [ "consultation" set-word-prop ] 2bi ;

PREDICATE: consult-method < method-body "consultation" word-prop ;

M: consult-method reset-word
    [ call-next-method ] [ f "consultation" set-word-prop ] bi ;

: consult-method-quot ( quot word -- object )
    [ second [ [ dip ] curry ] times ] [ first ] bi
    '[ _ call _ execute ] ;

: consult-method ( word consultation -- )
    [ create-consult-method ]
    [ quot>> swap consult-method-quot ] 2bi
    define ;

: change-word-prop ( word prop quot -- )
    [ swap props>> ] dip change-at ; inline

: each-generic ( consultation quot -- )
    [ [ group>> group-words ] keep ] dip curry each ; inline

: register-consult ( consultation -- )
    [ group>> \ protocol-consult ] [ ] [ class>> ] tri
    '[ [ _ _ ] dip ?set-at ] change-word-prop ;

: consult-methods ( consultation -- )
    [ consult-method ] each-generic ;

: unregister-consult ( consultation -- )
    [ class>> ] [ group>> ] bi
    \ protocol-consult word-prop delete-at ;

: unconsult-method ( word consultation -- )
    [ class>> swap first method ] keep
    over [
        over "consultation" word-prop eq?
        [ forget ] [ drop ] if
    ] [ 2drop ] if ;

: unconsult-methods ( consultation -- )
    [ unconsult-method ] each-generic ;

PRIVATE>

: define-consult ( consultation -- )
    [ register-consult ] [ consult-methods ] bi ;

SYNTAX: CONSULT:
    scan-word scan-word parse-definition <consultation>
    [ save-location ] [ define-consult ] bi ;

M: consultation where loc>> ;

M: consultation set-where (>>loc) ;

M: consultation forget*
    [ unconsult-methods ] [ unregister-consult ] bi ;

! Protocols
<PRIVATE

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
    [ drop protocol-consult values ] [ added-words ] 2bi
    [ swap consult-method ] cross-2each ;

: initialize-protocol-props ( protocol wordlist -- )
    [
        drop \ protocol-consult
        [ H{ } assoc-like ] change-word-prop
    ] [ { } like \ protocol-words set-word-prop ] 2bi ;

: fill-in-depth ( wordlist -- wordlist' )
    [ dup word? [ 0 2array ] when ] map ;

: show-words ( wordlist' -- wordlist )
    [ dup second zero? [ first ] when ] map ;

PRIVATE>

: define-protocol ( protocol wordlist -- )
    [ drop define-symbol ] [
        fill-in-depth
        [ forget-old-definitions ]
        [ add-new-definitions ]
        [ initialize-protocol-props ] 2tri
    ] 2bi ;

SYNTAX: PROTOCOL:
    CREATE-WORD parse-definition define-protocol ;

PREDICATE: protocol < word protocol-words ; ! Subclass of symbol?

M: protocol forget*
    [ f forget-old-definitions ] [ call-next-method ] bi ;


M: protocol definition protocol-words show-words ;

M: protocol definer drop \ PROTOCOL: \ ; ;

M: protocol group-words protocol-words ;

SYNTAX: SLOT-PROTOCOL:
    CREATE-WORD ";" parse-tokens
    [ [ reader-word ] [ writer-word ] bi 2array ] map concat
    define-protocol ;