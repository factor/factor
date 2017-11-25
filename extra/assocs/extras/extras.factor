! Copyright (C) 2012 John Benediktsson, Doug Coleman
! See http://factorcode.org/license.txt for BSD license
USING: arrays assocs assocs.private generalizations kernel math
sequences ;
IN: assocs.extras

: deep-at ( assoc seq -- value/f )
    [ of ] each ; inline

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

: if-assoc-empty ( ..a assoc quot1: ( ..a -- ..b ) quot2: ( ..a assoc -- ..b ) -- ..b )
    [ dup assoc-empty? ] [ [ drop ] prepose ] [ ] tri* if ; inline

: assoc-merge! ( assoc1 assoc2 -- assoc1 )
    over [ push-at ] with-assoc assoc-each ;

: assoc-merge ( assoc1 assoc2 -- newassoc )
    [ [ [ assoc-size ] bi@ + ] [ drop ] 2bi new-assoc ] 2keep
    [ assoc-merge! ] bi@ ;

GENERIC: delete-value-at ( value assoc -- )

M: assoc delete-value-at
    [ value-at* ] keep swap [ delete-at ] [ 2drop ] if ;

ERROR: key-exists value key assoc ;
: set-once-at ( value key assoc -- )
    2dup ?at [
        key-exists
    ] [
        drop set-at
    ] if ;

<PRIVATE

: (sequence>assoc) ( seq map-quot insert-quot assoc -- assoc )
    [ swap curry compose each ] keep ; inline

: (sequence-index>assoc) ( seq map-quot insert-quot assoc -- assoc )
    [ swap curry compose each-index ] keep ; inline

PRIVATE>

: sequence>assoc! ( assoc seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) -- assoc )
    4 nrot (sequence>assoc) ; inline

: sequence>assoc ( seq map-quot insert-quot exemplar -- assoc )
    clone (sequence>assoc) ; inline

: sequence-index>assoc ( seq map-quot insert-quot exemplar -- assoc )
    clone (sequence-index>assoc) ; inline

: sequence-index>hashtable ( seq map-quot insert-quot -- hashtable )
    H{ } sequence-index>assoc ; inline

: sequence>hashtable ( seq map-quot insert-quot -- hashtable )
    H{ } sequence>assoc ; inline
