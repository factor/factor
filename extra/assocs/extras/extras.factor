! Copyright (C) 2012 John Benediktsson, Doug Coleman
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs assocs.private kernel sequences ;

IN: assocs.extras

: assoc-harvest ( assoc -- assoc' )
    [ nip empty? not ] assoc-filter ; inline

: deep-at ( assoc seq -- value/f )
    [ swap at ] each ; inline

: zip-as ( keys values exemplar -- assoc )
    dup sequence? [
        [ 2array ] swap 2map-as
    ] [
        [ dup length ] dip new-assoc
        [ [ set-at ] with-assoc 2each ] keep
    ] if ; inline

: substitute! ( seq assoc -- seq )
    substituter map! ;

: assoc-reduce ( ... assoc identity quot: ( ... prev key value -- next ) -- ... result )
    [ >alist ] 2dip [ first2 ] prepose reduce ; inline

: reduce-keys ( ... assoc identity quot: ( ... prev elt -- ... next ) -- ... result )
    [ drop ] prepose assoc-reduce ; inline

: reduce-values ( ... assoc identity quot: ( ... prev elt -- ... next ) -- ... result )
    [ nip ] prepose assoc-reduce ; inline

: sum-keys ( assoc -- n ) 0 [ + ] reduce-keys ; inline

: sum-values ( assoc -- n ) 0 [ + ] reduce-values ; inline


