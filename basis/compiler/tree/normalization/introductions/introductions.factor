! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences accessors math kernel
compiler.tree ;
IN: compiler.tree.normalization.introductions

SYMBOL: introductions

GENERIC: count-introductions* ( node -- )

: count-introductions ( nodes -- n )
    #! Note: we use each, not each-node, since the #branch
    #! method recurses into children directly and we don't
    #! recurse into #recursive at all.
    [
        0 introductions set
        [ count-introductions* ] each
        introductions get
    ] with-scope ;

: introductions+ ( n -- ) introductions [ + ] change ;

M: #introduce count-introductions*
    out-d>> length introductions+ ;

M: #branch count-introductions*
    children>>
    [ count-introductions ] map supremum
    introductions+ ;

M: #recursive count-introductions*
    [ label>> ] [ child>> count-introductions ] bi
    >>introductions
    drop ;

M: node count-introductions* drop ;
