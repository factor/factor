! Copyright (C) 2004, 2008 Chris Double, Matthew Willis, James Cash.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators io kernel lists math
promises quotations sequences ;
IN: lists.lazy

M: promise car force car ;

M: promise cdr force cdr ;

M: promise nil? force nil? ;

TUPLE: lazy-cons-state { car promise } { cdr promise } ;

C: <lazy-cons-state> lazy-cons-state

: lazy-cons ( car cdr -- promise )
    '[ _ _ <lazy-cons-state> ] <promise> ;

M: lazy-cons-state car car>> force ;

M: lazy-cons-state cdr cdr>> force ;

M: lazy-cons-state nil? car nil? ;

: 1lazy-list ( a -- lazy-cons )
    [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
    1lazy-list 1quotation lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
    2lazy-list 1quotation lazy-cons ;

TUPLE: memoized-cons original car cdr nil? ;

SYMBOL: +not-memoized+

: <memoized-cons> ( cons -- memoized-cons )
    +not-memoized+ +not-memoized+ +not-memoized+
    memoized-cons boa ;

M: memoized-cons car
    dup car>> +not-memoized+ eq? [
        dup original>> car [ >>car drop ] keep
    ] [
        car>>
    ] if ;

M: memoized-cons cdr
    dup cdr>> +not-memoized+ eq? [
        dup original>> cdr [ >>cdr drop ] keep
    ] [
        cdr>>
    ] if ;

M: memoized-cons nil?
    dup nil?>> +not-memoized+ eq? [
        dup original>> nil? [ >>nil? drop ] keep
    ] [
        nil?>>
    ] if ;

TUPLE: lazy-map cons quot ;

C: <lazy-map> lazy-map

: lmap-lazy ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-map> <memoized-cons> ] if ;

M: lazy-map car
    [ cons>> car ] [ quot>> call( old -- new ) ] bi ;

M: lazy-map cdr
    [ cons>> cdr ] [ quot>> lmap-lazy ] bi ;

M: lazy-map nil?
    cons>> nil? ;

TUPLE: lazy-take n cons ;

C: <lazy-take> lazy-take

: ltake ( n list -- result )
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;

M: lazy-take car
    cons>> car ;

M: lazy-take cdr
    [ n>> 1 - ] [ cons>> cdr ltake ] bi ;

M: lazy-take nil?
    dup n>> zero? [ drop t ] [ cons>> nil? ] if ;

TUPLE: lazy-until cons quot ;

C: <lazy-until> lazy-until

: luntil ( list quot: ( elt -- ? ) -- result )
    over nil? [ drop ] [ <lazy-until> ] if ;

M: lazy-until car
    cons>> car ;

M: lazy-until cdr
    [ [ cons>> cdr ] [ quot>> ] bi ]
    [ [ cons>> car ] [ quot>> ] bi call( elt -- ? ) ] bi
    [ 2drop nil ] [ luntil ] if ;

M: lazy-until nil?
    drop f ;

TUPLE: lazy-while cons quot ;

C: <lazy-while> lazy-while

: lwhile ( list quot: ( elt -- ? ) -- result )
    over nil? [ drop ] [ <lazy-while> ] if ;

M: lazy-while car
    cons>> car ;

M: lazy-while cdr
    [ cons>> cdr ] keep quot>> lwhile ;

M: lazy-while nil?
    [ car ] keep quot>> call( elt -- ? ) not ;

TUPLE: lazy-filter cons quot ;

C: <lazy-filter> lazy-filter

: lfilter ( list quot: ( elt -- ? ) -- result )
    over nil? [ 2drop nil ] [ <lazy-filter> <memoized-cons> ] if ;

<PRIVATE

: car-filtered? ( lazy-filter -- ? )
    [ cons>> car ] [ quot>> ] bi call( elt -- ? ) ;

: skip ( lazy-filter -- lazy-filter )
    [ cdr ] change-cons ;

PRIVATE>

M: lazy-filter car
    dup car-filtered? [ cons>> ] [ skip ] if car ;

M: lazy-filter cdr
    dup car-filtered? [
        [ cons>> cdr ] [ quot>> ] bi lfilter
    ] [
        skip cdr
    ] if ;

M: lazy-filter nil?
    {
        { [ dup cons>> nil? ] [ drop t ] }
        { [ dup car-filtered? ] [ drop f ] }
        [ skip nil? ]
    } cond ;

TUPLE: lazy-append list1 list2 ;

C: <lazy-append> lazy-append

: lappend-lazy ( list1 list2 -- result )
    over nil? [ nip ] [ <lazy-append> ] if ;

M: lazy-append car
    list1>> car ;

M: lazy-append cdr
    [ list1>> cdr ] [ list2>> ] bi lappend-lazy ;

M: lazy-append nil?
    drop f ;

TUPLE: lazy-from-by n quot ;

: lfrom-by ( n quot: ( n -- o ) -- result ) lazy-from-by boa ; inline

: lfrom ( n -- result )
    [ 1 + ] lfrom-by ;

M: lazy-from-by car
    n>> ;

M: lazy-from-by cdr
    [ n>> ] [ quot>> ] bi [ call( old -- new ) ] keep lfrom-by ;

M: lazy-from-by nil?
    drop f ;

TUPLE: lazy-zip list1 list2 ;

C: <lazy-zip> lazy-zip

: lzip ( list1 list2 -- result )
    2dup [ nil? ] either?
    [ 2drop nil ] [ <lazy-zip> ] if ;

M: lazy-zip car
    [ list1>> car ] keep list2>> car 2array ;

M: lazy-zip cdr
    [ list1>> cdr ] keep list2>> cdr lzip ;

M: lazy-zip nil?
    drop f ;

TUPLE: sequence-cons index seq ;

C: <sequence-cons> sequence-cons

: sequence-tail>list ( index seq -- list )
    2dup length >= [
        2drop nil
    ] [
        <sequence-cons>
    ] if ;

M: sequence-cons car
    [ index>> ] [ seq>> nth ] bi ;

M: sequence-cons cdr
    [ index>> 1 + ] [ seq>> sequence-tail>list ] bi ;

M: sequence-cons nil?
    drop f ;

M: sequence >list 0 swap sequence-tail>list ;

TUPLE: lazy-concat car cdr ;

C: <lazy-concat> lazy-concat

DEFER: lconcat

<PRIVATE

: (lconcat) ( car cdr -- list )
    over nil? [ nip lconcat ] [ <lazy-concat> ] if ;

PRIVATE>

: lconcat ( list -- result )
    dup nil? [ drop nil ] [ uncons (lconcat) ] if ;

M: lazy-concat car
    car>> car ;

M: lazy-concat cdr
    [ car>> cdr ] keep cdr>> (lconcat) ;

M: lazy-concat nil?
    dup car>> nil? [ cdr>> nil?  ] [ drop f ] if ;

: lcartesian-product ( list1 list2 -- result )
    swap [ swap [ 2array ] with lmap-lazy ] with lmap-lazy lconcat ;

: lcartesian-product* ( lists -- result )
    dup nil? [
        drop nil
    ] [
        uncons
        [ car lcartesian-product ] [ cdr ] bi
        list>array swap [
            swap [ swap [ suffix ] with lmap-lazy ] with lmap-lazy lconcat
        ] reduce
    ] if ;

: lcartesian-map ( list quot: ( elt1 elt2 -- newelt ) -- result )
    [ lcartesian-product* ] dip [ first2 ] prepose lmap-lazy ;

: lcartesian-map* ( list guards quot: ( elt1 elt2 -- newelt ) -- result )
    [ [ [ first2 ] prepose ] map ] [ [ first2 ] prepose ] bi*
    [ [ lcartesian-product* ] dip [ lfilter ] each ] dip lmap-lazy ;

DEFER: lmerge

<PRIVATE

:: (lmerge) ( list1 list2 -- result )
    [ list1 car ]
    [
        [ list2 car ]
        [ list1 cdr list2 cdr lmerge ]
        lazy-cons
    ] lazy-cons ;

PRIVATE>

: lmerge ( list1 list2 -- result )
    {
        { [ over nil? ] [ nip ] }
        { [ dup nil? ] [ drop ] }
        [ (lmerge) ]
    } cond ;

TUPLE: lazy-io stream car cdr quot ;

C: <lazy-io> lazy-io

: lcontents ( stream -- result )
    f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
    f f [ stream-readln ] <lazy-io> ;

M: lazy-io car
    dup car>> [
        nip
    ] [
        dup [ stream>> ] [ quot>> ] bi
        call( stream -- value ) [ >>car ] [ drop nil ] if*
    ] if* ;

M: lazy-io cdr
    dup cdr>> dup [
        nip
    ] [
        drop dup [ stream>> ] [ quot>> ] [ car ] tri
        [
            [ f f ] dip <lazy-io> [ >>cdr drop ] keep
        ] [
            3drop nil
        ] if
    ] if ;

M: lazy-io nil?
    car nil? ;

INSTANCE: sequence-cons list
INSTANCE: memoized-cons list
INSTANCE: promise list
INSTANCE: lazy-io list
INSTANCE: lazy-concat list
INSTANCE: lazy-cons-state list
INSTANCE: lazy-map list
INSTANCE: lazy-take list
INSTANCE: lazy-append list
INSTANCE: lazy-from-by list
INSTANCE: lazy-zip list
INSTANCE: lazy-while list
INSTANCE: lazy-until list
INSTANCE: lazy-filter list
