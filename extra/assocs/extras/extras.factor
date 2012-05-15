! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: assocs kernel sequences ;

IN: assocs.extras

: assoc-harvest ( assoc -- assoc' )
    [ nip empty? not ] assoc-filter ; inline

: assoc-sift ( assoc -- assoc' )
    [ nip ] assoc-filter ; inline

: deep-at ( assoc seq -- value/f )
    [ swap at ] each ;
