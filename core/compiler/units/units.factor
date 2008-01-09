! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel continuations assocs namespaces sequences words
vocabs definitions hashtables ;
IN: compiler.units

SYMBOL: old-definitions
SYMBOL: new-definitions

TUPLE: redefine-error def ;

: redefine-error ( definition -- )
    \ redefine-error construct-boa
    { { "Continue" t } } throw-restarts drop ;

: add-once ( key assoc -- )
    2dup key? [ over redefine-error ] when dupd set-at ;

: (remember-definition) ( definition loc assoc -- )
    >r over set-where r> add-once ;

: remember-definition ( definition loc -- )
    new-definitions get first (remember-definition) ;

: remember-class ( class loc -- )
    over new-definitions get first key? [ dup redefine-error ] when
    new-definitions get second (remember-definition) ;

TUPLE: forward-error word ;

: forward-error ( word -- )
    \ forward-error construct-boa throw ;

: forward-reference? ( word -- ? )
    dup old-definitions get assoc-stack
    [ new-definitions get assoc-stack not ]
    [ drop f ] if ;

SYMBOL: recompile-hook

: <definitions> ( -- pair ) { H{ } H{ } } [ clone ] map ;

SYMBOL: definition-observers

definition-observers global [ V{ } like ] change-at

GENERIC: definitions-changed ( assoc obj -- )

: add-definition-observer ( obj -- )
    definition-observers get push ;

: remove-definition-observer ( obj -- )
    definition-observers get delete ;

: notify-definition-observers ( assoc -- )
    definition-observers get
    [ definitions-changed ] curry* each ;

: changed-vocabs ( -- assoc )
    changed-words get
    [ drop word-vocabulary dup [ vocab ] when dup ] assoc-map ;

: changed-definitions ( -- assoc )
    H{ } clone
    dup new-definitions get first update
    dup new-definitions get second update
    dup changed-words get update
    dup changed-vocabs update ;

: finish-compilation-unit ( -- )
    changed-definitions notify-definition-observers
    changed-words get keys recompile-hook get call ;

: with-compilation-unit ( quot -- )
    [
        H{ } clone changed-words set
        <definitions> new-definitions set
        <definitions> old-definitions set
        [ finish-compilation-unit ]
        [ ] cleanup
    ] with-scope ; inline

recompile-hook global
[ [ [ f ] { } map>assoc modify-code-heap ] or ]
change-at
