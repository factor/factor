! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006
!
USING: kernel sequences math vectors arrays namespaces generic ;
IN: lazy-lists

TUPLE: promise quot forced? value ;

C: promise ( quot -- promise ) [ set-promise-quot ] keep ;

: force ( promise -- value )
    #! Force the given promise leaving the value of calling the
    #! promises quotation on the stack. Re-forcing the promise
    #! will return the same value and not recall the quotation.
    dup promise-forced? [
        dup promise-quot call over set-promise-value
        t over set-promise-forced?
    ] unless
    promise-value ;

TUPLE: cons car cdr ;
GENERIC: car  ( cons -- car )
GENERIC: cdr  ( cons -- cdr )
GENERIC: nil? ( cons -- bool )

C: cons ( car cdr -- list ) 
    [ set-cons-cdr ] keep 
    [ set-cons-car ] keep ;

M: cons car ( cons -- car )
    cons-car ;    

M: cons cdr ( cons -- cdr )
    cons-cdr ;    

: nil ( -- cons )
  T{ cons f f f } ;

M: cons nil? ( cons -- bool )
    nil eq? ;

: cons ( car cdr -- list )
    <cons> ;

: 1list ( obj -- cons )
    nil <cons> ;

: 2list ( a b -- cons )
    nil <cons> <cons> ;

: 3list ( a b c -- cons )
    nil <cons> <cons> <cons> ;

! Both 'car' and 'cdr' are promises  
: lazy-cons ( car cdr -- promise ) 
    >r <promise> r> <promise> <cons> 
    T{ promise f f t f } clone [ set-promise-value ] keep ;

M: promise car ( promise -- car )
  force car force ;

M: promise cdr ( promise -- cdr )
  force cdr force ;

M: promise nil? ( cons -- bool )
  force nil? ;

DEFER: lunit 
DEFER: lnth 
TUPLE: list ;

: 1lazy-list ( a -- lazy-cons )
  [ nil ] lazy-cons ;

: 2lazy-list ( a b -- lazy-cons )
  1lazy-list unit lazy-cons ;

: 3lazy-list ( a b c -- lazy-cons )
  2lazy-list unit lazy-cons ;

: lnth ( n list -- elt ) 
  swap [ cdr ] times car ;

: uncons ( cons -- car cdr )
    #! Return the car and cdr of the lazy list
    dup car swap cdr ;

: leach ( list quot -- )
  swap dup nil? [ 
    2drop 
  ] [
    uncons swap pick call swap leach
  ] if ;

: 2curry ( a b quot -- quot )
  curry curry ;

TUPLE: memoized-cons original car cdr nil? ;

: not-memoized ( -- obj )
  { } ;

: not-memoized? ( obj -- bool )
  not-memoized eq? ;

C: memoized-cons ( cons -- memoized-cons )
  [ set-memoized-cons-original ] keep
  not-memoized over set-memoized-cons-car 
  not-memoized over set-memoized-cons-cdr 
  not-memoized over set-memoized-cons-nil? ;

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

TUPLE: lazy-map cons quot ;

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

TUPLE: lazy-map-with value cons quot ;

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

TUPLE: lazy-take n cons ;

: ltake ( n list -- result )
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;
     
M: lazy-take car ( lazy-take -- car )
  lazy-take-cons car ;

M: lazy-take cdr ( lazy-take -- cdr )
  [ lazy-take-n 1- ] keep
  lazy-take-cons cdr ltake ;

M: lazy-take nil? ( lazy-take -- bool )
  lazy-take-n zero? ;

TUPLE: lazy-subset cons quot ;

: lsubset ( list quot -- list )
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

: list>vector ( list -- vector )
  [ [ , ] leach ] V{ } make ;

: list>array ( list -- array )
  [ [ , ] leach ] { } make ;

TUPLE: lazy-append list1 list2 ;

: lappend ( list1 list2 -- result )
  {
    { [ over nil? over nil? and ] [ 2drop nil ] }
    { [ over nil? ] [ nip ] }
    { [ dup nil? ] [ drop ] }
    { [ t ] [ <lazy-append> ] }
  } cond ;

M: lazy-append car ( lazy-append -- car )
  lazy-append-list1 car ;

M: lazy-append cdr ( lazy-append -- cdr )
  [ lazy-append-list1 cdr  ] keep
  lazy-append-list2 lappend ;

M: lazy-append nil? ( lazy-append -- bool )
  dup lazy-append-list1 nil? [
    drop t 
  ] [
    lazy-append-list2 nil? 
  ] if ;

TUPLE: lazy-from-by n quot ;

: lfrom-by ( n quot -- list )
  <lazy-from-by> ;
    
: lfrom ( n -- list )
  [ 1 + ] lfrom-by ;

M: lazy-from-by car ( lazy-from-by -- car )
  lazy-from-by-n ;

M: lazy-from-by cdr ( lazy-from-by -- cdr )
  [ lazy-from-by-n ] keep
  lazy-from-by-quot dup >r call r> lfrom-by ;

M: lazy-from-by nil? ( lazy-from-by -- bool )
  drop f ;
  
TUPLE: lazy-zip list1 list2 ;

: lzip ( list1 list2 -- lazy-zip )
    over nil? over nil? or 
    [ 2drop nil ] [ <lazy-zip> ] if ;

M: lazy-zip car ( lazy-zip -- car )
    [ lazy-zip-list1 car ] keep lazy-zip-list2 car 2array ;
   
M: lazy-zip cdr ( lazy-zip -- cdr )
    [ lazy-zip-list1 cdr ] keep lazy-zip-list2 cdr lzip ;

M: lazy-zip nil? ( lazy-zip -- bool )
    drop f ;
    
: seq>list ( seq -- list )
  reverse nil [ swap cons ] reduce ;

: lconcat ( list -- result )
  list>array nil [ lappend ] reduce ;

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

: lcomp2 ( list1 list2 quot -- list )
  >r lcartesian-product r> swap [ swap >r first2 r> call ] lmap-with  ;

: lcomp3 ( list1 list2 list3 quot -- list )
  >r 3array seq>list lcartesian-product* r> swap [ swap >r first3 r> call ] lmap-with  ;