! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs assocs.private kernel sequences ;

IN: assocs.extras

: assoc-harvest ( assoc -- assoc' )
    [ nip empty? not ] assoc-filter ; inline

: assoc-sift ( assoc -- assoc' )
    [ nip ] assoc-filter ; inline

: deep-at ( assoc seq -- value/f )
    [ swap at ] each ;

: zip-as ( keys values exemplar -- assocs )
    dup sequence? [
        [ 2array ] swap 2map-as
    ] [
        [ dup length ] dip new-assoc
        [ [ set-at ] with-assoc 2each ] keep
    ] if ;
