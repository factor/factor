! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: fry kernel math sequences splitting strings wrap ;
IN: wrap.strings

<PRIVATE

: split-lines ( string -- elements-lines )
    string-lines [
        " \t" split harvest
        [ dup length 1 <element> ] map!
    ] map! ;

: join-elements ( wrapped-lines -- lines )
    [ " " join ] map! ;

: join-lines ( strings -- string )
    "\n" join ;

PRIVATE>

: wrap-lines ( string width -- newlines )
    [ split-lines ] dip '[ _ wrap join-elements ] map! concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

<PRIVATE

: make-indent ( indent -- indent' )
    dup string? [ CHAR: \s <string> ] unless ; inline

PRIVATE>

: wrap-indented-string ( string width indent -- newstring )
    make-indent [ length - wrap-lines ] keep
    over empty? [ nip ] [ '[ _ prepend ] map! join-lines ] if ;
