! Copyright (C) 2012 John Benediktsson, Doug Coleman
! See http://factorcode.org/license.txt for BSD license
USING: arrays assocs assocs.private fry generalizations kernel
math math.statistics sequences sequences.extras ;
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

: assoc-invert-as ( assoc exemplar -- newassoc )
    [ swap ] swap assoc-map-as ;

: assoc-invert ( assoc -- newassoc )
    dup assoc-invert-as ;

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

: kv-with ( obj assoc quot -- assoc curried )
    swapd [ -rotd call ] 2curry ; inline

<PRIVATE

: (sequence>assoc) ( seq map-quot insert-quot assoc -- assoc )
    [ swap curry compose each ] keep ; inline

: (sequence-index>assoc) ( seq map-quot insert-quot assoc -- assoc )
    [ swap curry compose each-index ] keep ; inline

PRIVATE>

: sequence>assoc! ( assoc seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) -- assoc )
    roll (sequence>assoc) ; inline

: assoc>object ( assoc map-quot insert-quot exemplar -- object )
    clone [ swap curry compose assoc-each ] keep ; inline

: assoc>object! ( assoc seq map-quot: ( x -- ..y ) insert-quot: ( ..y assoc -- ) -- object )
    roll assoc>object ; inline

: sequence>assoc ( seq map-quot insert-quot exemplar -- assoc )
    clone (sequence>assoc) ; inline

: sequence-index>assoc ( seq map-quot insert-quot exemplar -- assoc )
    clone (sequence-index>assoc) ; inline

: sequence-index>hashtable ( seq map-quot insert-quot -- hashtable )
    H{ } sequence-index>assoc ; inline

: sequence>hashtable ( seq map-quot insert-quot -- hashtable )
    H{ } sequence>assoc ; inline

: expand-keys-set-at-as ( assoc exemplar -- hashtable' )
    [
        [ swap dup sequence? [ 1array ] unless ]
        [ '[ _ set-at ] with each ]
    ] dip assoc>object ;

: expand-keys-set-at ( assoc -- hashtable' )
    H{ } expand-keys-set-at-as ;

: expand-keys-push-at-as ( assoc exemplar -- hashtable' )
    [
        [ swap dup sequence? [ 1array ] unless ]
        [ '[ _ push-at ] with each ]
    ] dip assoc>object ;

: expand-keys-push-at ( assoc -- hashtable' )
    H{ } expand-keys-push-at-as ; inline

: expand-keys-push-as ( assoc exemplar -- hashtable' )
    [
        [ [ dup sequence? [ 1array ] unless ] dip ]
        [ '[ _ 2array _ push ] each ]
    ] dip assoc>object ;

: expand-keys-push ( assoc -- hashtable' )
    V{ } expand-keys-push-as ; inline

: expand-values-set-at-as ( assoc exemplar -- hashtable' )
    [
        [ dup sequence? [ 1array ] unless swap ]
        [ '[ _ _ set-at ] each ]
    ] dip assoc>object ;

: expand-values-set-at ( assoc -- hashtable' )
    H{ } expand-values-set-at-as ; inline

: expand-values-push-at-as ( assoc exemplar -- hashtable' )
    [
        [ dup sequence? [ 1array ] unless swap ]
        [ '[ _ _ push-at ] each ]
    ] dip assoc>object ;

: expand-values-push-at ( assoc -- assoc )
    H{ } expand-values-push-at-as ; inline

: expand-values-push-as ( assoc exemplar -- assoc )
    [
        [ dup sequence? [ 1array ] unless ]
        [ '[ 2array _ push ] with each ]
    ] dip assoc>object ;

: expand-values-push ( assoc -- sequence )
    V{ } expand-values-push-as ; inline

: assoc-any-key? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ drop ] prepose assoc-find 2nip ; inline

: assoc-any-value? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ nip ] prepose assoc-find 2nip ; inline

: assoc-all-key? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ not ] compose assoc-any-key? not  ; inline

: assoc-all-value? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ not ] compose assoc-any-value? not  ; inline

: any-multi-key? ( assoc -- ? )
    [ sequence? ] assoc-any-key? ;

: any-multi-value? ( assoc -- ? )
    [ sequence? ] assoc-any-value? ;

: flatten-keys ( assoc -- assoc' )
    dup any-multi-key? [ expand-keys-set-at flatten-keys ] when ;

: flatten-values ( assoc -- assoc' )
    dup any-multi-value? [ expand-values-set-at flatten-values ] when ;

: intersect-keys ( assoc seq -- elts )
    [ of ] with map-zip sift-values ; inline

: values-of ( assoc seq -- elts )
    [ of ] with map sift ; inline

: counts ( seq elts -- counts )
    [ histogram ] dip intersect-keys ;