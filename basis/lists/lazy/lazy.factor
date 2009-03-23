! Copyright (C) 2004, 2008 Chris Double, Matthew Willis, James Cash.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences math vectors arrays namespaces make
quotations promises combinators io lists accessors ;
IN: lists.lazy

M: promise car ( promise -- car )
    force car ;

M: promise cdr ( promise -- cdr )
    force cdr ;

M: promise nil? ( cons -- bool )
    force nil? ;
    
! Both 'car' and 'cdr' are promises
TUPLE: lazy-cons car cdr ;

: lazy-cons ( car cdr -- promise )
    [ promise ] bi@ \ lazy-cons boa
    T{ promise f f t f } clone
        swap >>value ;

M: lazy-cons car ( lazy-cons -- car )
    car>> force ;

M: lazy-cons cdr ( lazy-cons -- cdr )
    cdr>> force ;

M: lazy-cons nil? ( lazy-cons -- bool )
    nil eq? ;

: 1lazy-list ( a -- lazy-cons )
    [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
    1lazy-list 1quotation lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
    2lazy-list 1quotation lazy-cons ;

TUPLE: memoized-cons original car cdr nil? ;

: not-memoized ( -- obj )
    { } ;

: not-memoized? ( obj -- bool )
    not-memoized eq? ;

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

M: memoized-cons nil? ( memoized-cons -- bool )
    dup nil?>> not-memoized? [
        dup original>> nil?  [ >>nil? drop ] keep
    ] [
        nil?>>
    ] if ;

TUPLE: lazy-map cons quot ;

C: <lazy-map> lazy-map

: lazy-map ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-map> <memoized-cons> ] if ;

M: lazy-map car ( lazy-map -- car )
    [ cons>> car ] keep
    quot>> call( old -- new ) ;

M: lazy-map cdr ( lazy-map -- cdr )
    [ cons>> cdr ] keep
    quot>> lazy-map ;

M: lazy-map nil? ( lazy-map -- bool )
    cons>> nil? ;

TUPLE: lazy-take n cons ;

C: <lazy-take> lazy-take

: ltake ( n list -- result )
        over zero? [ 2drop nil ] [ <lazy-take> ] if ;

M: lazy-take car ( lazy-take -- car )
    cons>> car ;

M: lazy-take cdr ( lazy-take -- cdr )
    [ n>> 1- ] keep
    cons>> cdr ltake ;

M: lazy-take nil? ( lazy-take -- bool )
    dup n>> zero? [
        drop t
    ] [
        cons>> nil?
    ] if ;

TUPLE: lazy-until cons quot ;

C: <lazy-until> lazy-until

: luntil ( list quot -- result )
    over nil? [ drop ] [ <lazy-until> ] if ;

M: lazy-until car ( lazy-until -- car )
     cons>> car ;

M: lazy-until cdr ( lazy-until -- cdr )
     [ cons>> unswons ] keep quot>> tuck call( elt -- ? )
     [ 2drop nil ] [ luntil ] if ;

M: lazy-until nil? ( lazy-until -- bool )
     drop f ;

TUPLE: lazy-while cons quot ;

C: <lazy-while> lazy-while

: lwhile ( list quot -- result )
    over nil? [ drop ] [ <lazy-while> ] if ;

M: lazy-while car ( lazy-while -- car )
     cons>> car ;

M: lazy-while cdr ( lazy-while -- cdr )
     [ cons>> cdr ] keep quot>> lwhile ;

M: lazy-while nil? ( lazy-while -- bool )
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

M: lazy-filter nil? ( lazy-filter -- bool )
    dup cons>> nil? [
        drop t
    ] [
        dup car-filter? [
            drop f
        ] [
            dup skip nil?
        ] if
    ] if ;

: list>vector ( list -- vector )
    [ [ , ] leach ] V{ } make ;

: list>array ( list -- array )
    [ [ , ] leach ] { } make ;

TUPLE: lazy-append list1 list2 ;

C: <lazy-append> lazy-append

: lappend ( list1 list2 -- result )
    over nil? [ nip ] [ <lazy-append> ] if ;

M: lazy-append car ( lazy-append -- car )
    list1>> car ;

M: lazy-append cdr ( lazy-append -- cdr )
    [ list1>> cdr    ] keep
    list2>> lappend ;

M: lazy-append nil? ( lazy-append -- bool )
     drop f ;

TUPLE: lazy-from-by n quot ;

C: lfrom-by lazy-from-by

: lfrom ( n -- list )
    [ 1+ ] lfrom-by ;

M: lazy-from-by car ( lazy-from-by -- car )
    n>> ;

M: lazy-from-by cdr ( lazy-from-by -- cdr )
    [ n>> ] keep
    quot>> [ call( old -- new ) ] keep lfrom-by ;

M: lazy-from-by nil? ( lazy-from-by -- bool )
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

M: lazy-zip nil? ( lazy-zip -- bool )
        drop f ;

TUPLE: sequence-cons index seq ;

C: <sequence-cons> sequence-cons

: seq>list ( index seq -- list )
    2dup length >= [
        2drop nil
    ] [
        <sequence-cons>
    ] if ;

M: sequence-cons car ( sequence-cons -- car )
    [ index>> ] keep
    seq>> nth ;

M: sequence-cons cdr ( sequence-cons -- cdr )
    [ index>> 1+ ] keep
    seq>> seq>list ;

M: sequence-cons nil? ( sequence-cons -- bool )
    drop f ;

: >list ( object -- list )
    {
        { [ dup sequence? ] [ 0 swap seq>list ] }
        { [ dup list?         ] [ ] }
        [ "Could not convert object to a list" throw ]
    } cond ;

TUPLE: lazy-concat car cdr ;

C: <lazy-concat> lazy-concat

DEFER: lconcat

: (lconcat) ( car cdr -- list )
    over nil? [
        nip lconcat
    ] [
        <lazy-concat>
    ] if ;

: lconcat ( list -- result )
    dup nil? [
        drop nil
    ] [
        uncons (lconcat)
    ] if ;

M: lazy-concat car ( lazy-concat -- car )
    car>> car ;

M: lazy-concat cdr ( lazy-concat -- cdr )
    [ car>> cdr ] keep cdr>> (lconcat) ;

M: lazy-concat nil? ( lazy-concat -- bool )
    dup car>> nil? [
        cdr>> nil?
    ] [
        drop f
    ] if ;

: lcartesian-product ( list1 list2 -- result )
    swap [ swap [ 2array ] with lazy-map  ] with lazy-map  lconcat ;

: lcartesian-product* ( lists -- result )
    dup nil? [
        drop nil
    ] [
        [ car ] keep cdr [ car lcartesian-product ] keep cdr list>array swap [
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
        { [ over nil? ] [ nip     ] }
        { [ dup nil?    ]    [ drop ] }
        { [ t                 ]    [ (lmerge) ] }
    } cond ;

TUPLE: lazy-io stream car cdr quot ;

C: <lazy-io> lazy-io

: lcontents ( stream -- result )
    f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
    f f [ stream-readln ] <lazy-io> ;

M: lazy-io car ( lazy-io -- car )
    dup car>> dup [
        nip
    ] [
        drop dup stream>> over quot>>
        call( stream -- value )
        >>car
    ] if ;

M: lazy-io cdr ( lazy-io -- cdr )
    dup cdr>> dup [
        nip
    ] [
        drop dup
        [ stream>> ] keep
        [ quot>> ] keep
        car [
            [ f f ] dip <lazy-io> [ >>cdr drop ] keep
        ] [
            3drop nil
        ] if
    ] if ;

M: lazy-io nil? ( lazy-io -- bool )
    car not ;

INSTANCE: sequence-cons list
INSTANCE: memoized-cons list
INSTANCE: promise list
INSTANCE: lazy-io list
INSTANCE: lazy-concat list
INSTANCE: lazy-cons list
INSTANCE: lazy-map list
INSTANCE: lazy-take list
INSTANCE: lazy-append list
INSTANCE: lazy-from-by list
INSTANCE: lazy-zip list
INSTANCE: lazy-while list
INSTANCE: lazy-until list
INSTANCE: lazy-filter list
