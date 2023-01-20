! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators compiler.tree
compiler.tree.combinators compiler.tree.propagation.info fry
hashtables kernel math math.partial-dispatch sequences words ;
IN: compiler.tree.identities

: define-identities ( word identities -- )
    [ integer-derived-ops dup empty? f assert= ] dip
    '[ _ "identities" set-word-prop ] each ;

SYMBOL: X

\ + {
    { { X 0 } drop }
    { { 0 X } nip }
} define-identities

\ - {
    { { X 0 } drop }
} define-identities

\ * {
    { { X 1 } drop }
    { { 1 X } nip }
    { { X 0 } nip }
    { { 0 X } drop }
} define-identities

\ bitand {
    { { X -1 } drop }
    { { -1 X } nip }
    { { X 0 } nip }
    { { 0 X } drop }
} define-identities

\ bitor {
    { { X 0 } drop }
    { { 0 X } nip }
    { { X -1 } nip }
    { { -1 X } drop }
} define-identities

\ bitxor {
    { { X 0 } drop }
    { { 0 X } nip }
} define-identities

\ shift {
    { { 0 X } drop }
    { { X 0 } drop }
} define-identities

: matches? ( pattern infos -- ? )
    [ over X eq? [ 2drop t ] [ literal>> = ] if ] 2all? ;

: find-identity ( patterns infos -- result )
    '[ first _ matches? ] find swap [ second ] when ;

GENERIC: apply-identities* ( node -- node )

: simplify-to-constant ( #call constant -- nodes )
    [ [ in-d>> <#drop> ] [ out-d>> first ] bi ] dip swap <#push>
    2array ;

: select-input ( node n -- #shuffle )
    [ [ in-d>> ] [ out-d>> ] bi ] dip
    pick nth over first associate <#data-shuffle> ;

M: #call apply-identities*
    dup word>> "identities" word-prop [
        over node-input-infos find-identity [
            {
                { \ drop [ 0 select-input ] }
                { \ nip [ 1 select-input ] }
                [ simplify-to-constant ]
            } case
        ] when*
    ] when* ;

M: node apply-identities* ;

: apply-identities ( nodes -- nodes' )
    [ apply-identities* ] map-nodes ;
