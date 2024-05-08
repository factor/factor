! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: arrays grouping kernel math namespaces sequences
splitting strings wrap ;
IN: wrap.strings

SYMBOL: break-long-words?

<PRIVATE

: wrap-split-line ( string width -- elements )
    [
        dup [ " \t" member? not ] find drop 0 or
        [ f swap ] [ cut ] if-zero
        " \t" split harvest break-long-words? get
    ] dip '[
        [ _ group [ dup length 1 <element> ] map ] map concat
    ] [
        [ dup length 1 <element> ] map
    ] if swap [ 0 over length <element> prefix ] when* ;

: wrap-split-lines ( string width -- elements-lines )
    [ split-lines ] dip '[ _ wrap-split-line ] map! ;

: join-elements ( wrapped-lines -- lines )
    [ join-words ] map! ;

PRIVATE>

: wrap-lines ( string width -- newlines )
    [ wrap-split-lines ] keep '[ _ wrap join-elements ] map! concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

<PRIVATE

: make-indent ( indent -- indent' )
    dup string? [ CHAR: \s <string> ] unless ; inline

PRIVATE>

: wrap-indented-string ( string width indent -- newstring )
    make-indent [ length - wrap-lines ] keep
    over empty? [ nip ] [ '[ _ prepend ] map! join-lines ] if ;
