! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006
! Updated by Chris Double, September 2006
!
USING: kernel sequences math vectors arrays namespaces generic errors ;
IN: lazy-lists

! Lazy List Protocol
GENERIC: car   ( cons -- car )
GENERIC: cdr   ( cons -- cdr )
GENERIC: nil?  ( cons -- bool )
GENERIC: list? ( object -- bool )

TUPLE: promise quot forced? value ;

C: promise ( quot -- promise ) [ set-promise-quot ] keep ;

: promise ( quot -- promise ) 
  <promise> ;

: promise-with ( value quot -- promise )
  curry <promise> ;

: promise-with2 ( value1 value2 quot -- promise )
  curry curry <promise> ;

: force ( promise -- value )
    #! Force the given promise leaving the value of calling the
    #! promises quotation on the stack. Re-forcing the promise
    #! will return the same value and not recall the quotation.
    dup promise-forced? [
        dup promise-quot call over set-promise-value
        t over set-promise-forced?
    ] unless
    promise-value ;

M: promise car ( promise -- car )
  force car ;

M: promise cdr ( promise -- cdr )
  force cdr ;

M: promise nil? ( cons -- bool )
  force nil? ;

M: promise list? ( object -- bool )
  drop t ;

TUPLE: cons car cdr ;

M: object list? ( object -- bool )
  drop f ;

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

M: cons list? ( object -- bool )
  drop t ;

: cons ( car cdr -- list )
    <cons> ;

: 1list ( obj -- cons )
    nil <cons> ;

: 2list ( a b -- cons )
    nil <cons> <cons> ;

: 3list ( a b c -- cons )
    nil <cons> <cons> <cons> ;

! Both 'car' and 'cdr' are promises  
TUPLE: lazy-cons car cdr ;

: lazy-cons ( car cdr -- promise ) 
    >r promise r> promise <lazy-cons> 
    T{ promise f f t f } clone [ set-promise-value ] keep ;

M: lazy-cons car ( lazy-cons -- car )
    lazy-cons-car force ;    

M: lazy-cons cdr ( lazy-cons -- cdr )
    lazy-cons-cdr force ;    

M: lazy-cons nil? ( lazy-cons -- bool )
    nil eq? ;

M: lazy-cons list? ( object -- bool )
  drop t ;

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

M: memoized-cons list? ( object -- bool )
  drop t ;

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

M: lazy-map list? ( object -- bool )
  drop t ;

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

M: lazy-map-with list? ( object -- bool )
  drop t ;

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

M: lazy-take list? ( object -- bool )
  drop t ;

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

M: lazy-subset list? ( object -- bool )
  drop t ;

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

M: lazy-append list? ( object -- bool )
  drop t ;

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
  
M: lazy-from-by list? ( object -- bool )
  drop t ;

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

M: lazy-zip list? ( object -- bool )
  drop t ;

TUPLE: sequence-cons index seq ;

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

: lcomp ( list quot -- result )
  >r lcartesian-product* r> lmap ;

: lcomp* ( list guards quot -- result )
  >r >r lcartesian-product* r> [ lsubset ] each r> lmap ;
