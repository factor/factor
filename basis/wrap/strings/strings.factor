! Copyright (C) 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: kernel math sequences splitting strings wrap ;
IN: wrap.strings

<PRIVATE

: wrap-split-line ( string -- elements )
    dup [ " \t" member? not ] find drop 0 or
    [ f swap ] [ cut ] if-zero
    " \t" split harvest [ dup length 1 <element> ] map!
    swap [ 0 over length <element> prefix ] when* ;

: wrap-split-lines ( string -- elements-lines )
    split-lines [ wrap-split-line ] map! ;

: join-elements ( wrapped-lines -- lines )
    [ join-words ] map! ;

PRIVATE>

: wrap-lines ( string width -- newlines )
    [ wrap-split-lines ] dip '[ _ wrap join-elements ] map! concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

<PRIVATE

: make-indent ( indent -- indent' )
    dup string? [ CHAR: \s <string> ] unless ; inline

PRIVATE>

: wrap-indented-string ( string width indent -- newstring )
    make-indent [ length - wrap-lines ] keep
    over empty? [ nip ] [ '[ _ prepend ] map! join-lines ] if ;
