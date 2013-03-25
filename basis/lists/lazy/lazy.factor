! Copyright (C) 2004, 2008 Chris Double, Matthew Willis, James Cash.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators io kernel lists math
promises quotations sequences summary vectors ;
IN: lists.lazy

M: promise car ( promise -- car )
    force car ;

M: promise cdr ( promise -- cdr )
    force cdr ;

M: promise nil? ( cons -- ? )
    force nil? ;
 
! Both 'car' and 'cdr' are promises
TUPLE: lazy-cons-state car cdr ;

: lazy-cons ( car cdr -- promise )
    [ T{ promise f f t f } clone ] 2dip
        [ <promise> ] bi@ \ lazy-cons-state boa
        >>value ;

M: lazy-cons-state car ( lazy-cons -- car )
    car>> force ;

M: lazy-cons-state cdr ( lazy-cons -- cdr )
    cdr>> force ;

M: lazy-cons-state nil? ( lazy-cons -- ? )
    nil eq? ;

: 1lazy-list ( a -- lazy-cons )
    [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
    1lazy-list 1quotation lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
    2lazy-list 1quotation lazy-cons ;

TUPLE: memoized-cons original car cdr nil? ;

: not-memoized ( -- obj ) { } ;

: not-memoized? ( obj -- ? ) not-memoized eq? ;

: <memoized-cons> ( cons -- memoized-cons )
    not-memoized not-memoized not-memoized
    memoized-cons boa ;

M: memoized-cons car ( memoized-cons -- car )
    dup car>> not-memoized? [
        dup original>> car [ >>car drop ] keep
    ] [
        car>>
    ] if ;

M: memoized-cons cdr ( memoized-cons -- cdr )
    dup cdr>> not-memoized? [
        dup original>> cdr [ >>cdr drop ] keep
    ] [
        cdr>>
    ] if ;

M: memoized-cons nil? ( memoized-cons -- ? )
    dup nil?>> not-memoized? [
        dup original>> nil?  [ >>nil? drop ] keep
    ] [
        nil?>>
    ] if ;

TUPLE: lazy-map-state cons quot ;

C: <lazy-map-state> lazy-map-state

: lazy-map ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-map-state> <memoized-cons> ] if ;

M: lazy-map-state car ( lazy-map -- car )
    [ cons>> car ] [ quot>> call( old -- new ) ] bi ;

M: lazy-map-state cdr ( lazy-map -- cdr )
    [ cons>> cdr ] [ quot>> lazy-map ] bi ;

M: lazy-map-state nil? ( lazy-map -- ? )
    cons>> nil? ;

TUPLE: lazy-take n cons ;

C: <lazy-take> lazy-take

: ltake ( n list -- result )
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;

M: lazy-take car ( lazy-take -- car )
    cons>> car ;

M: lazy-take cdr ( lazy-take -- cdr )
    [ n>> 1 - ] keep
    cons>> cdr ltake ;

M: lazy-take nil? ( lazy-take -- ? )
    dup n>> zero? [ drop t ] [ cons>> nil? ] if ;

TUPLE: lazy-until cons quot ;

C: <lazy-until> lazy-until

: luntil ( list quot -- result )
    over nil? [ drop ] [ <lazy-until> ] if ;

M: lazy-until car ( lazy-until -- car )
    cons>> car ;

M: lazy-until cdr ( lazy-until -- cdr )
    [ [ cons>> cdr ] [ quot>> ] bi ]
    [ [ cons>> car ] [ quot>> ] bi call( elt -- ? ) ] bi
    [ 2drop nil ] [ luntil ] if ;

M: lazy-until nil? ( lazy-until -- ? )
    drop f ;

TUPLE: lazy-while cons quot ;

C: <lazy-while> lazy-while

: lwhile ( list quot -- result )
    over nil? [ drop ] [ <lazy-while> ] if ;

M: lazy-while car ( lazy-while -- car )
    cons>> car ;

M: lazy-while cdr ( lazy-while -- cdr )
    [ cons>> cdr ] keep quot>> lwhile ;

M: lazy-while nil? ( lazy-while -- ? )
    [ car ] keep quot>> call( elt -- ? ) not ;

TUPLE: lazy-filter cons quot ;

C: <lazy-filter> lazy-filter

: lfilter ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-filter> <memoized-cons> ] if ;

: car-filter? ( lazy-filter -- ? )
    [ cons>> car ] [ quot>> ] bi call( elt -- ? ) ;

: skip ( lazy-filter -- )
    dup cons>> cdr >>cons drop ;

M: lazy-filter car ( lazy-filter -- car )
    dup car-filter? [ cons>> ] [ dup skip ] if car ;

M: lazy-filter cdr ( lazy-filter -- cdr )
    dup car-filter? [
        [ cons>> cdr ] [ quot>> ] bi lfilter
    ] [
        dup skip cdr
    ] if ;

M: lazy-filter nil? ( lazy-filter -- ? )
    dup cons>> nil? [
        drop t
    ] [
        dup car-filter? [
            drop f
        ] [
            dup skip nil?
        ] if
    ] if ;

TUPLE: lazy-append list1 list2 ;

C: <lazy-append> lazy-append

: lappend ( list1 list2 -- result )
    over nil? [ nip ] [ <lazy-append> ] if ;

M: lazy-append car ( lazy-append -- car )
    list1>> car ;

M: lazy-append cdr ( lazy-append -- cdr )
    [ list1>> cdr ] [ list2>> ] bi lappend ;

M: lazy-append nil? ( lazy-append -- ? )
     drop f ;

TUPLE: lazy-from-by n quot ;

: lfrom-by ( n quot: ( n -- o ) -- lazy-from-by ) lazy-from-by boa ; inline

: lfrom ( n -- list )
    [ 1 + ] lfrom-by ;

M: lazy-from-by car ( lazy-from-by -- car )
    n>> ;

M: lazy-from-by cdr ( lazy-from-by -- cdr )
    [ n>> ] keep
    quot>> [ call( old -- new ) ] keep lfrom-by ;

M: lazy-from-by nil? ( lazy-from-by -- ? )
    drop f ;

TUPLE: lazy-zip list1 list2 ;

C: <lazy-zip> lazy-zip

: lzip ( list1 list2 -- lazy-zip )
        over nil? over nil? or
        [ 2drop nil ] [ <lazy-zip> ] if ;

M: lazy-zip car ( lazy-zip -- car )
        [ list1>> car ] keep list2>> car 2array ;

M: lazy-zip cdr ( lazy-zip -- cdr )
        [ list1>> cdr ] keep list2>> cdr lzip ;

M: lazy-zip nil? ( lazy-zip -- ? )
        drop f ;

TUPLE: sequence-cons index seq ;

C: <sequence-cons> sequence-cons

: sequence-tail>list ( index seq -- list )
    2dup length >= [
        2drop nil
    ] [
        <sequence-cons>
    ] if ;

M: sequence-cons car ( sequence-cons -- car )
    [ index>> ] [ seq>> nth ] bi ;

M: sequence-cons cdr ( sequence-cons -- cdr )
    [ index>> 1 + ] [ seq>> sequence-tail>list ] bi ;

M: sequence-cons nil? ( sequence-cons -- ? )
    drop f ;

ERROR: list-conversion-error object ;

M: list-conversion-error summary
    drop "Could not convert object to list" ;

: >list ( object -- list )
    {
        { [ dup sequence? ] [ 0 swap sequence-tail>list ] }
        { [ dup list? ] [ ] }
        [ list-conversion-error ]
    } cond ;

TUPLE: lazy-concat car cdr ;

C: <lazy-concat> lazy-concat

DEFER: lconcat

: (lconcat) ( car cdr -- list )
    over nil? [ nip lconcat ] [ <lazy-concat> ] if ;

: lconcat ( list -- result )
    dup nil? [ drop nil ] [ uncons (lconcat) ] if ; 

M: lazy-concat car ( lazy-concat -- car )
    car>> car ;

M: lazy-concat cdr ( lazy-concat -- cdr )
    [ car>> cdr ] keep cdr>> (lconcat) ;

M: lazy-concat nil? ( lazy-concat -- ? )
    dup car>> nil? [ cdr>> nil?  ] [ drop f ] if ;

: lcartesian-product ( list1 list2 -- result )
    swap [ swap [ 2array ] with lazy-map  ] with lazy-map  lconcat ;

: lcartesian-product* ( lists -- result )
    dup nil? [
        drop nil
    ] [
        uncons
        [ car lcartesian-product ] [ cdr ] bi
        list>array swap [
            swap [ swap [ suffix ] with lazy-map  ] with lazy-map  lconcat
        ] reduce
    ] if ;

: lcomp ( list quot -- result )
    [ lcartesian-product* ] dip lazy-map ;

: lcomp* ( list guards quot -- result )
    [ [ lcartesian-product* ] dip [ lfilter ] each ] dip lazy-map ;

DEFER: lmerge

: (lmerge) ( list1 list2 -- result )
    over [ car ] curry -rot
    [
        dup [ car ] curry -rot
        [
            [ cdr ] bi@ lmerge
        ] 2curry lazy-cons
    ] 2curry lazy-cons ;

: lmerge ( list1 list2 -- result )
    {
        { [ over nil? ] [ nip ] }
        { [ dup nil? ] [ drop ] }
        { [ t ] [ (lmerge) ] }
    } cond ;

TUPLE: lazy-io stream car cdr quot ;

C: <lazy-io> lazy-io

: lcontents ( stream -- result )
    f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
    f f [ stream-readln ] <lazy-io> ;

M: lazy-io car ( lazy-io -- car )
    dup car>> [
        nip
    ] [
        [ ] [ stream>> ] [ quot>> ] tri
        call( stream -- value ) [ >>car ] [ drop nil ] if*
    ] if* ;

M: lazy-io cdr ( lazy-io -- cdr )
    dup cdr>> dup [
        nip
    ] [
        drop dup
        [ stream>> ]
        [ quot>> ]
        [ car ] tri [
            [ f f ] dip <lazy-io> [ >>cdr drop ] keep
        ] [
            3drop nil
        ] if
    ] if ;

M: lazy-io nil? ( lazy-io -- ? )
    car nil? ;

INSTANCE: sequence-cons list
INSTANCE: memoized-cons list
INSTANCE: promise list
INSTANCE: lazy-io list
INSTANCE: lazy-concat list
INSTANCE: lazy-cons-state list
INSTANCE: lazy-map-state list
INSTANCE: lazy-take list
INSTANCE: lazy-append list
INSTANCE: lazy-from-by list
INSTANCE: lazy-zip list
INSTANCE: lazy-while list
INSTANCE: lazy-until list
INSTANCE: lazy-filter list
