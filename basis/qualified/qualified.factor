! Copyright (C) 2007, 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences assocs hashtables parser lexer
vocabs words namespaces vocabs.loader sets fry ;
IN: qualified

: define-qualified ( vocab-name prefix-name -- )
    [ load-vocab vocab-words ] [ CHAR: : suffix ] bi*
    '[ [ [ _ ] dip append ] dip ] assoc-map
    use get push ;

: QUALIFIED:
    #! Syntax: QUALIFIED: vocab
    scan dup define-qualified ; parsing

: QUALIFIED-WITH:
    #! Syntax: QUALIFIED-WITH: vocab prefix
    scan scan define-qualified ; parsing

: partial-vocab ( words vocab -- assoc )
    '[ dup _ lookup [ no-word-error ] unless* ]
    { } map>assoc ;

: FROM:
    #! Syntax: FROM: vocab => words... ;
    scan dup load-vocab drop "=>" expect
    ";" parse-tokens swap partial-vocab use get push ; parsing

: partial-vocab-excluding ( words vocab -- assoc )
    [ load-vocab vocab-words keys swap diff ] keep partial-vocab ;

: EXCLUDE:
    #! Syntax: EXCLUDE: vocab => words ... ;
    scan "=>" expect
    ";" parse-tokens swap partial-vocab-excluding use get push ; parsing

: RENAME:
    #! Syntax: RENAME: word vocab => newname
    scan scan dup load-vocab drop
    dupd lookup [ ] [ no-word-error ] ?if
    "=>" expect
    scan associate use get push ; parsing

