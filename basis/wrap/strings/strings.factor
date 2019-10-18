! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: wrap kernel sequences fry splitting math ;
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

: wrap-lines ( lines width -- newlines )
    [ split-lines ] dip '[ _ dup wrap join-elements ] map! concat ;

: wrap-string ( string width -- newstring )
    wrap-lines join-lines ;

: wrap-indented-string ( string width indent -- newstring )
    [ length - wrap-lines ] keep '[ _ prepend ] map! join-lines ;
