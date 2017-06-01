! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math sequences fry ;
IN: crypto.xor

: mod-nth ( n seq -- elt ) [ length mod ] [ nth ] bi ;

ERROR: empty-xor-key ;

: xor-crypt ( seq key -- seq' )
    [ empty-xor-key ] when-empty
    [ dup length <iota> ] dip '[ _ mod-nth bitxor ] 2map ;
