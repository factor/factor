! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: kernel

: 2drop ( x x -- ) drop drop ; inline
: 3drop ( x x x -- ) drop drop drop ; inline
: 2dup ( x y -- x y x y ) over over ; inline
: 3dup ( x y z -- x y z x y z ) pick pick pick ; inline
: rot ( x y z -- y z x ) >r swap r> swap ; inline
: -rot ( x y z -- z x y ) swap >r swap r> ; inline
: dupd ( x y -- x x y ) >r dup r> ; inline
: swapd ( x y z -- y x z ) >r swap r> ; inline
: 2swap ( x y z t -- z t x y ) rot >r rot r> ; inline
: nip ( x y -- y ) swap drop ; inline
: 2nip ( x y z -- z ) >r drop drop r> ; inline
: tuck ( x y -- y x y ) dup >r swap r> ; inline

: clear ( -- )
    #! Clear the datastack. For interactive use only; invoking
    #! this from a word definition will clobber any values left
    #! on the data stack by the caller.
    { } set-datastack ;
