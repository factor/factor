! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006
!
USING: kernel sequences math vectors arrays namespaces
quotations promises combinators io ;
IN: lazy-lists

! Lazy List Protocol
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?  ( cons -- ? )
GENERIC: list? ( object -- ? )

M: object list? ( object -- bool )
  drop f ;

M: promise car ( promise -- car )
  force car ;

M: promise cdr ( promise -- cdr )
  force cdr ;

M: promise nil? ( cons -- bool )
  force nil? ;

M: promise list? ( object -- bool )
  drop t ;

TUPLE: cons car cdr ;

C: cons cons

M: cons car ( cons -- car )
    cons-car ;

M: cons cdr ( cons -- cdr )
    cons-cdr ;

: nil ( -- cons )
  T{ cons f f f } ;

M: cons nil? ( cons -- bool )
    nil eq? ;

M: cons list? ( object -- bool )
  drop t ;

: 1list ( obj -- cons )
    nil cons ;

: 2list ( a b -- cons )
    nil cons cons ;

: 3list ( a b c -- cons )
    nil cons cons cons ;

! Both 'car' and 'cdr' are promises
TUPLE: lazy-cons car cdr ;

: lazy-cons ( car cdr -- promise )
    [ promise ] 2apply \ lazy-cons construct-boa
    T{ promise f f t f } clone
    [ set-promise-value ] keep ;

M: lazy-cons car ( lazy-cons -- car )
    lazy-cons-car force ;

M: lazy-cons cdr ( lazy-cons -- cdr )
    lazy-cons-cdr force ;

M: lazy-cons nil? ( lazy-cons -- bool )
    nil eq? ;

M: lazy-cons list? ( object -- bool )
  drop t ;

: 1lazy-list ( a -- lazy-cons )
  [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
  1lazy-list 1quotation lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
  2lazy-list 1quotation lazy-cons ;

: lnth ( n list -- elt )
  swap [ cdr ] times car ;

: (llength) ( list acc -- n )
  over nil? [ nip ] [ >r cdr r> 1+ (llength) ] if ;

: llength ( list -- n )
  0 (llength) ;

: uncons ( cons -- car cdr )
    #! Return the car and cdr of the lazy list
    dup car swap cdr ;

: leach ( list quot -- )
  swap dup nil? [
    2drop
  ] [
    uncons swap pick call swap leach
  ] if ;

TUPLE: memoized-cons original car cdr nil? ;

: not-memoized ( -- obj )
  { } ;

: not-memoized? ( obj -- bool )
  not-memoized eq? ;

: <memoized-cons> ( cons -- memoized-cons )
  not-memoized not-memoized not-memoized
  memoized-cons construct-boa ;

M: memoized-cons car ( memoized-cons -- car )
  dup memoized-cons-car not-memoized? [
    dup memoized-cons-original car [ swap set-memoized-cons-car ] keep
  ] [
    memoized-cons-car
  ] if ;

M: memoized-cons cdr ( memoized-cons -- cdr )
  dup memoized-cons-cdr not-memoized? [
    dup memoized-cons-original cdr [ swap set-memoized-cons-cdr ] keep
  ] [
    memoized-cons-cdr
  ] if ;

M: memoized-cons nil? ( memoized-cons -- bool )
  dup memoized-cons-nil? not-memoized? [
    dup memoized-cons-original nil? [ swap set-memoized-cons-nil? ] keep
  ] [
    memoized-cons-nil?
  ] if ;

M: memoized-cons list? ( object -- bool )
  drop t ;

TUPLE: lazy-map cons quot ;

C: <lazy-map> lazy-map

: lmap ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-map> <memoized-cons> ] if ;

M: lazy-map car ( lazy-map -- car )
  [ lazy-map-cons car ] keep
  lazy-map-quot call ;

M: lazy-map cdr ( lazy-map -- cdr )
  [ lazy-map-cons cdr ] keep
  lazy-map-quot lmap ;

M: lazy-map nil? ( lazy-map -- bool )
  lazy-map-cons nil? ;

M: lazy-map list? ( object -- bool )
  drop t ;

TUPLE: lazy-map-with value cons quot ;

C: <lazy-map-with> lazy-map-with

: lmap-with ( value list quot -- result )
  over nil? [ 3drop nil ] [ <lazy-map-with> <memoized-cons> ] if ;

M: lazy-map-with car ( lazy-map-with -- car )
  [ lazy-map-with-value ] keep
  [ lazy-map-with-cons car ] keep
  lazy-map-with-quot call ;

M: lazy-map-with cdr ( lazy-map-with -- cdr )
  [ lazy-map-with-value ] keep
  [ lazy-map-with-cons cdr ] keep
  lazy-map-with-quot lmap-with ;

M: lazy-map-with nil? ( lazy-map-with -- bool )
  lazy-map-with-cons nil? ;

M: lazy-map-with list? ( object -- bool )
  drop t ;

TUPLE: lazy-take n cons ;

C: <lazy-take> lazy-take

: ltake ( n list -- result )
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;

M: lazy-take car ( lazy-take -- car )
  lazy-take-cons car ;

M: lazy-take cdr ( lazy-take -- cdr )
  [ lazy-take-n 1- ] keep
  lazy-take-cons cdr ltake ;

M: lazy-take nil? ( lazy-take -- bool )
  dup lazy-take-n zero? [
    drop t
  ] [
    lazy-take-cons nil?
  ] if ;

M: lazy-take list? ( object -- bool )
  drop t ;

TUPLE: lazy-subset cons quot ;

C: <lazy-subset> lazy-subset

: lsubset ( list quot -- result )
    over nil? [ 2drop nil ] [ <lazy-subset> <memoized-cons> ] if ;

: car-subset?  ( lazy-subset -- )
  [ lazy-subset-cons car ] keep
  lazy-subset-quot call ;

: skip ( lazy-subset -- )
  [ lazy-subset-cons cdr ] keep
  set-lazy-subset-cons ;

M: lazy-subset car ( lazy-subset -- car )
  dup car-subset? [
    lazy-subset-cons car
  ] [
    dup skip car
  ] if ;

M: lazy-subset cdr ( lazy-subset -- cdr )
  dup car-subset? [
    [ lazy-subset-cons cdr ] keep
    lazy-subset-quot lsubset
  ] [
    dup skip cdr
  ] if ;

M: lazy-subset nil? ( lazy-subset -- bool )
  dup lazy-subset-cons nil? [
    drop t
  ] [
    dup car-subset? [
      drop f
    ] [
      dup skip nil?
    ] if
  ] if ;

M: lazy-subset list? ( object -- bool )
  drop t ;

: list>vector ( list -- vector )
  [ [ , ] leach ] V{ } make ;

: list>array ( list -- array )
  [ [ , ] leach ] { } make ;

TUPLE: lazy-append list1 list2 ;

C: <lazy-append> lazy-append

: lappend ( list1 list2 -- result )
  over nil? [ nip ] [ <lazy-append> ] if ;

M: lazy-append car ( lazy-append -- car )
  lazy-append-list1 car ;

M: lazy-append cdr ( lazy-append -- cdr )
  [ lazy-append-list1 cdr  ] keep
  lazy-append-list2 lappend ;

M: lazy-append nil? ( lazy-append -- bool )
  dup lazy-append-list1 nil? [
    lazy-append-list2 nil?
  ] [
    drop f
  ] if ;

M: lazy-append list? ( object -- bool )
  drop t ;

TUPLE: lazy-from-by n quot ;

C: lfrom-by lazy-from-by ( n quot -- list )

: lfrom ( n -- list )
  [ 1 + ] lfrom-by ;

M: lazy-from-by car ( lazy-from-by -- car )
  lazy-from-by-n ;

M: lazy-from-by cdr ( lazy-from-by -- cdr )
  [ lazy-from-by-n ] keep
  lazy-from-by-quot dup >r call r> lfrom-by ;

M: lazy-from-by nil? ( lazy-from-by -- bool )
  drop f ;

M: lazy-from-by list? ( object -- bool )
  drop t ;

TUPLE: lazy-zip list1 list2 ;

C: <lazy-zip> lazy-zip

: lzip ( list1 list2 -- lazy-zip )
    over nil? over nil? or
    [ 2drop nil ] [ <lazy-zip> ] if ;

M: lazy-zip car ( lazy-zip -- car )
    [ lazy-zip-list1 car ] keep lazy-zip-list2 car 2array ;

M: lazy-zip cdr ( lazy-zip -- cdr )
    [ lazy-zip-list1 cdr ] keep lazy-zip-list2 cdr lzip ;

M: lazy-zip nil? ( lazy-zip -- bool )
    drop f ;

M: lazy-zip list? ( object -- bool )
  drop t ;

TUPLE: sequence-cons index seq ;

C: <sequence-cons> sequence-cons

: seq>list ( index seq -- list )
  2dup length >= [
    2drop nil
  ] [
    <sequence-cons>
  ] if ;

M: sequence-cons car ( sequence-cons -- car )
  [ sequence-cons-index ] keep
  sequence-cons-seq nth ;

M: sequence-cons cdr ( sequence-cons -- cdr )
  [ sequence-cons-index 1+ ] keep
  sequence-cons-seq seq>list ;

M: sequence-cons nil? ( sequence-cons -- bool )
    drop f ;

M: sequence-cons list? ( object -- bool )
  drop t ;

: >list ( object -- list )
  {
    { [ dup sequence? ] [ 0 swap seq>list ] }
    { [ dup list?     ] [ ] }
    { [ t ] [ "Could not convert object to a list" throw ] }
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
  lazy-concat-car car ;

M: lazy-concat cdr ( lazy-concat -- cdr )
  [ lazy-concat-car cdr ] keep lazy-concat-cdr (lconcat) ;

M: lazy-concat nil? ( lazy-concat -- bool )
  dup lazy-concat-car nil? [
    lazy-concat-cdr nil?
  ] [
    drop f
  ] if ;

M: lazy-concat list? ( object -- bool )
  drop t ;

: lcartesian-product ( list1 list2 -- result )
  swap [ swap [ 2array ] lmap-with ] lmap-with lconcat ;

: lcartesian-product* ( lists -- result )
  dup nil? [
    drop nil
  ] [
    [ car ] keep cdr [ car lcartesian-product ] keep cdr list>array swap [
      swap [ swap [ add ] lmap-with ] lmap-with lconcat
    ] reduce
  ] if ;

: lcomp ( list quot -- result )
  >r lcartesian-product* r> lmap ;

: lcomp* ( list guards quot -- result )
  >r >r lcartesian-product* r> [ lsubset ] each r> lmap ;

DEFER: lmerge

: (lmerge) ( list1 list2 -- result )
  over [ car ] curry -rot
  [
    dup [ car ] curry -rot
    [
      >r cdr r> cdr lmerge
    ] 2curry lazy-cons
  ] 2curry lazy-cons ;

: lmerge ( list1 list2 -- result )
  {
    { [ over nil? ] [ nip   ] }
    { [ dup nil?  ]  [ drop ] }
    { [ t         ]  [ (lmerge) ] }
  } cond ;

TUPLE: lazy-io stream car cdr quot ;

C: <lazy-io> lazy-io

: lcontents ( stream -- result )
  f f [ stream-read1 ] <lazy-io> ;

: llines ( stream -- result )
  f f [ stream-readln ] <lazy-io> ;

M: lazy-io car ( lazy-io -- car )
  dup lazy-io-car dup [
    nip
  ] [
    drop dup lazy-io-stream over lazy-io-quot call
    swap dupd set-lazy-io-car
  ] if ;

M: lazy-io cdr ( lazy-io -- cdr )
  dup lazy-io-cdr dup [
    nip
  ] [
    drop dup
    [ lazy-io-stream ] keep
    [ lazy-io-quot ] keep
    car [
      >r f f r> <lazy-io> [ swap set-lazy-io-cdr ] keep
    ] [
      3drop nil
    ] if
  ] if ;

M: lazy-io nil? ( lazy-io -- bool )
  car not ;
