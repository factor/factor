! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences math accessors kernel arrays
stack-checker.backend compiler.tree compiler.tree.combinators ;
IN: compiler.tree.normalization

! A transform pass done before optimization can begin to
! fix up some oddities in the tree output by the stack checker:
!
! - We rewrite the code is that #introduce nodes only appear
! at the top level, and not inside #recursive. This enables more
! accurate type inference for 'row polymorphic' combinators.
!
! - We collect #return-recursive and #call-recursive nodes and
! store them in the #recursive's label slot.

GENERIC: normalize* ( node -- )

! Collect introductions
SYMBOL: introductions

GENERIC: collect-introductions* ( node -- )

: collect-introductions ( nodes -- n )
    [
        0 introductions set
        [ collect-introductions* ] each
        introductions get
    ] with-scope ;

M: #introduce collect-introductions* drop introductions inc ;

M: #branch collect-introductions*
    children>>
    [ collect-introductions ] map supremum
    introductions [ + ] change ;

M: node collect-introductions* drop ;

! Eliminate introductions
SYMBOL: introduction-stack

: fixup-enter-recursive ( recursive -- )
    [ child>> first ] [ in-d>> ] bi >>in-d
    [ introduction-stack get prepend ] change-out-d
    drop ;

GENERIC: eliminate-introductions* ( node -- node' )

: pop-introduction ( -- value )
    introduction-stack [ unclip-last swap ] change ;

M: #introduce eliminate-introductions*
    pop-introduction swap value>> [ 1array ] bi@ #copy ;

SYMBOL: remaining-introductions

M: #branch eliminate-introductions*
    dup children>> [
        [
            [ eliminate-introductions* ] change-each
            introduction-stack get
        ] with-scope
    ] map
    [ remaining-introductions set ]
    [ [ length ] map infimum introduction-stack [ swap head ] change ]
    bi ;

M: #phi eliminate-introductions*
    remaining-introductions get swap
    [ flip [ over length tail append ] 2map flip ] change-phi-in-d ;

M: node eliminate-introductions* ;

: eliminate-introductions ( recursive n -- )
    make-values introduction-stack set
    [ fixup-enter-recursive ]
    [ child>> [ eliminate-introductions* ] change-each ] bi ;

M: #recursive normalize*
    [
        [ child>> collect-introductions ]
        [ swap eliminate-introductions ]
        bi
    ] with-scope ;

! Collect label info
M: #return-recursive normalize* dup label>> (>>return) ;

M: #call-recursive normalize* dup label>> calls>> push ;

M: node normalize* drop ;

: normalize ( node -- node ) dup [ normalize* ] each-node ;
