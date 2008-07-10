! Copyright (C) 2008 William Schlieper
! See http://factorcode.org/license.txt for BSD license.

USING: kernel continuations sequences namespaces fry ;

IN: backtrack

SYMBOL: failure

: amb ( seq -- elt )
    failure get
    '[ , _ '[ , '[ failure set , , continue-with ] callcc0 ] each
       , continue ] callcc1 ;

: fail ( -- )
    f amb drop ;

: require ( ? -- )
    [ fail ] unless ;

