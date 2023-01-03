! Copyright (C) 2012 John Benediktsson, Doug Coleman
! See http://factorcode.org/license.txt for BSD license
USING: arrays assocs assocs.private kernel math math.statistics
sequences sets ;
IN: assocs.extras

: push-at-each ( value keys assoc -- )
    '[ _ push-at ] with each ; inline

: deep-of ( assoc seq -- value/f )
    [ of ] each ; inline

: deep-of-but-last ( assoc seq -- obj key )
    unclip-last [ [ of ] each ] dip ; inline

: deep-change-of ( assoc seq quot -- )
    [ deep-of-but-last swap ] dip change-at ; inline

: deep-set-of ( assoc seq elt -- )
    [ deep-of-but-last ] dip spin set-at ; inline

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

: map-keys ( assoc quot: ( key -- key' ) -- assoc )
    '[ _ dip ] assoc-map ; inline

: map-values ( assoc quot: ( value -- value' ) -- assoc )
    '[ swap _ dip swap ] assoc-map ; inline

: filter-keys ( assoc quot: ( key -- key' ) -- assoc' )
    '[ drop @ ] assoc-filter ; inline

: filter-values ( assoc quot: ( value -- value' ) -- assoc' )
    '[ nip @ ] assoc-filter ; inline

: reject-keys ( assoc quot: ( key -- key' ) -- assoc' )
    '[ drop @ ] assoc-reject ; inline

: reject-values ( assoc quot: ( value -- value' ) -- assoc' )
    '[ nip @ ] assoc-reject ; inline

: rekey-new-assoc ( assoc keys -- newassoc )
    [ tuck of ] with H{ } map>assoc ; inline

: rekey-assoc ( assoc keys -- assoc )
    [ dup keys ] dip diff over [ delete-at ] curry each ; inline

: if-assoc-empty ( ..a assoc quot1: ( ..a -- ..b ) quot2: ( ..a assoc -- ..b ) -- ..b )
    [ dup assoc-empty? ] [ [ drop ] prepose ] [ ] tri* if ; inline

: assoc-invert-as ( assoc exemplar -- newassoc )
    [ swap ] swap assoc-map-as ;

: assoc-invert ( assoc -- newassoc )
    dup assoc-invert-as ;

: assoc-collect! ( assoc1 assoc2 -- assoc1 )
    over [ push-at ] with-assoc assoc-each ;

: assoc-collect ( assoc1 assoc2 -- newassoc )
    [ [ [ assoc-size ] bi@ + ] [ drop ] 2bi new-assoc ] 2keep
    [ assoc-collect! ] bi@ ;

! iterate over assoc2, replace conflicting values
! Modifies assoc1
: assoc-merge! ( assoc1 assoc2 quot: ( value1 value2 -- new-value ) -- assoc1' )
    [| key2 val2 quot | val2 key2 pick
     at* [ swap quot call ] [ drop ] if
     key2 pick set-at ] curry assoc-each ; inline

! Same as above, non-destructive
: assoc-merge ( assoc1 assoc2 quot: ( value1 value2 -- new-value ) -- new-assoc )
    pick [ [ clone ] 2dip assoc-merge! ]
    [ drop nip ] if
    ; inline

! Successively apply assoc-merge operation
: assoc-collapse ( seq quot: ( value1 value2 -- new-value ) -- assoc )
    over empty?
    [ 2drop f ]
    [ [ unclip-slice H{ } or clone ] [ [ assoc-merge! ] curry ] bi* reduce ] if ; inline

: assoc-collapse! ( assoc seq quot: ( value1 value2 -- new-value ) -- assoc )
    [ assoc-merge! ] curry each ; inline

: assoc-collapse-as ( seq quot: ( value1 value2 -- new-value ) exemplar -- assoc )
    pick first assoc-size swap new-assoc
    -rot assoc-collapse! ; inline

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
        [ push-at-each ]
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

: assoc-any-value? ( ... assoc quot: ( ... value -- ... ? ) -- ... ? )
    [ nip ] prepose assoc-find 2nip ; inline

: assoc-all-key? ( ... assoc quot: ( ... key -- ... ? ) -- ... ? )
    [ not ] compose assoc-any-key? not ; inline

: assoc-all-value? ( ... assoc quot: ( ... value -- ... ? ) -- ... ? )
    [ not ] compose assoc-any-value? not ; inline

: any-multi-key? ( assoc -- ? )
    [ sequence? ] assoc-any-key? ;

: any-multi-value? ( assoc -- ? )
    [ sequence? ] assoc-any-value? ;

: flatten-keys ( assoc -- assoc' )
    dup any-multi-key? [ expand-keys-set-at flatten-keys ] when ;

: flatten-values ( assoc -- assoc' )
    dup any-multi-value? [ expand-values-set-at flatten-values ] when ;

: intersect-keys-as ( assoc seq exemplar -- elts )
  [ [ of ] with ] dip zip-with-as sift-values ; inline

: intersect-keys ( assoc seq -- elts )
    over intersect-keys-as ; inline

: values-of ( assoc seq -- seq' )
    [ of ] with map ; inline

: counts ( seq elts -- counts )
    [ histogram ] dip intersect-keys ;

: histogram-diff ( hashtable1 hashtable2 -- hashtable3 )
    [ neg swap pick at+ ] assoc-each
    [ 0 > ] filter-values ;

: collect-by-multi! ( ... assoc seq quot: ( ... obj -- ... new-keys ) -- ... assoc )
    [ keep swap ] curry rot [
        [ push-at-each ] curry compose each
    ] keep ; inline

: collect-by-multi ( ... seq quot: ( ... obj -- ... new-keys ) -- ... assoc )
    [ H{ } clone ] 2dip collect-by-multi! ; inline


: collect-assoc-by! ( ... assoc input-assoc quot: ( ... key value -- ... key' value' ) -- ... assoc )
    rot [ '[ @ swap _ push-at ] assoc-each ] keep ; inline

: collect-assoc-by ( ... input-assoc quot: ( ... key value -- ... key value ) -- ... assoc )
    [ H{ } clone ] 2dip collect-assoc-by! ; inline

: collect-key-by! ( ... assoc input-assoc quot: ( ... key value -- ... new-key ) -- ... assoc )
    '[ _ keepd ] collect-assoc-by! ; inline

: collect-key-by ( ... input-assoc quot: ( ... key value -- ... new-key ) -- ... assoc )
    [ H{ } clone ] 2dip collect-key-by! ; inline

: collect-value-by! ( ... assoc input-assoc quot: ( ... key value -- ... new-key ) -- ... assoc )
    '[ _ keep ] collect-assoc-by! ; inline

: collect-value-by ( ... input-assoc quot: ( ... key value -- ... new-key ) -- ... assoc )
    [ H{ } clone ] 2dip collect-value-by! ; inline


: collect-assoc-by-multi! ( ... assoc input-assoc quot: ( ... key value -- ... new-keys value' ) -- ... assoc )
    rot [ '[ @ swap _ push-at-each ] assoc-each ] keep ; inline

: collect-assoc-by-multi ( ... assoc quot: ( ... key value -- ... new-keys value' ) -- ... assoc )
    [ H{ } clone ] 2dip collect-assoc-by-multi! ; inline


: collect-key-by-multi! ( ... assoc input-assoc quot: ( ... key value -- ... new-keys ) -- ... assoc )
    '[ _ keepd ] collect-assoc-by-multi! ; inline

: collect-key-by-multi ( ... assoc quot: ( ... key -- ... new-keys ) -- ... assoc )
    [ H{ } clone ] 2dip collect-key-by-multi! ; inline


: collect-value-by-multi! ( ... assoc input-assoc quot: ( ... key value -- ... new-keys ) -- ... assoc )
    '[ _ keep ] collect-assoc-by-multi! ; inline

: collect-value-by-multi ( ... assoc quot: ( ... value -- ... new-keys ) -- ... assoc )
    [ H{ } clone ] 2dip collect-value-by-multi! ; inline
