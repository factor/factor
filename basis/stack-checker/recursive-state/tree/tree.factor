! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel sequences math math.order ;
IN: stack-checker.recursive-state.tree

! Persistent unbalanced hash tree using eq? comparison.
! We use this to speed up stack-checker.recursive-state.
! Perhaps this should go somewhere else

TUPLE: node value key hashcode left right ;

GENERIC: lookup ( key node -- value/f )

M: f lookup nip ;

: decide ( key node -- key node ? )
    over hashcode over hashcode>> <= ; inline

M: node lookup
    2dup key>> eq?
    [ nip value>> ]
    [ decide [ left>> ] [ right>> ] if lookup ] if ;

GENERIC: store ( value key node -- node' )

M: f store drop dup hashcode f f node boa ;

M: node store
    clone decide
    [ [ store ] change-left ]
    [ [ store ] change-right ] if ;
