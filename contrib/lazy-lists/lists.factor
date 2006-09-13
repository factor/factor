! Copyright (C) 2004 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
! Updated by Matthew Willis, July 2006

USING: kernel sequences math vectors arrays namespaces generic ;
IN: lazy-lists

TUPLE: cons car cdr ;
GENERIC: car ( cons -- car )
GENERIC: cdr ( cons -- cdr )

C: cons ( car cdr -- list ) 
    [ set-cons-cdr ] keep 
    [ set-cons-car ] keep ;

M: cons car ( cons -- car )
    cons-car ;    

M: cons cdr ( cons -- cdr )
    cons-cdr ;

: nil ( -- list )
    { } ;

: nil? ( list -- bool )
    { } = ;

: cons ( car cdr -- list )
    <cons> ;

: 1list ( obj -- cons )
    nil <cons> ;

: 2list ( obj obj -- cons )
    nil <cons> <cons> ;

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

! Both 'car' and 'cdr' are promises  
: lazy-cons ( car cdr -- promise ) 
    >r <promise> r> <promise> <cons> 
    T{ promise f f t f } clone [ set-promise-value ] keep ;

M: promise car ( promise -- car )
  force car force ;

M: promise cdr ( promise -- cdr )
  force cdr force ;

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
    
: 2curry ( a b quot -- quot )
  curry curry ;

TUPLE: lazy-map cons quot ;

: lmap ( list quot -- list )
    #! Return a lazy list containing the collected result of calling
    #! quot on the original lazy list.
    over nil? [ drop ] [ <lazy-map> ] if ;

M: lazy-map car ( lazy-map -- car )
  [ lazy-map-cons car ] keep
  lazy-map-quot call ;

M: lazy-map cdr ( lazy-map -- cdr )
  [ lazy-map-cons cdr ] keep
  lazy-map-quot lmap ;

TUPLE: lazy-take n cons ;

: ltake ( n list -- list )
    #! Return a lazy list containing the first n items from
    #! the original lazy list.
    over zero? [ 2drop nil ] [ <lazy-take> ] if ;
     
M: lazy-take car ( lazy-take -- car )
  lazy-take-cons car ;

M: lazy-take cdr ( lazy-take -- cdr )
  [ lazy-take-n 1- ] keep
  lazy-take-cons cdr ltake ;

DEFER: lsubset
: (lsubset) ( list pred -- list )
	>r dup nil? [ r> drop ] 
	[
		uncons swap dup r> dup >r call 
		[ swap r> lsubset cons ] 
		[ drop r> (lsubset) ] if
	] if ;
	
: lsubset-car ( array pred -- value )
  2dup >r first car dup r> call [
    2nip 
  ] [
    drop >r dup first cdr 0 pick set-nth r> lsubset-car
  ] if ;

! cons needs to be lazy so lsubset can lazilly detect nil!
! It needs to skip all 'f' entries on initial call.
: lsubset ( list pred -- list )
    #! Return a lazy list containing the elements in llist 
    #! satisfying pred	
    over nil? [    
      drop
    ] [ 
      >r 1array r> 2dup [ >r first cdr r> lsubset ] 2curry >r [ lsubset-car ] 2curry r> cons  
    ] if ;

: t1 
  [ 1 ] [ [ 2 ] [ [ 3 ] [ nil ] cons ] cons ] cons ;

: t2
  [ 2 ] [ [ 3 ] [ [ 4 ] [ nil ] cons ] cons ] cons ;

: (list>backwards-vector) ( list -- vector )
    dup nil? [ drop V{ } clone ]
	[ uncons (list>backwards-vector) swap over push ] if ;
	
: list>vector ( list -- vector )
    #! Convert a lazy list to a vector. This will cause
    #! an infinite loop if the lazy list is an infinite list.
    (list>backwards-vector) reverse ;

: list>array ( list -- array )
    list>vector >array ;

DEFER: backwards-vector>list
: (backwards-vector>list) ( vector -- list )
    dup empty? [ drop nil ]
	[ dup pop swap backwards-vector>list cons ] if ;

DEFER: force-promise

: backwards-vector>list ( vector -- list )
    [ , \ (backwards-vector>list) , ] force-promise ;
    
: array>list ( array -- list )
    #! Convert a list to a lazy list.
    reverse >vector backwards-vector>list ;

DEFER: lappend*
: (lappend*) ( lists -- list )
	dup nil? [ 
		uncons >r dup nil? [ drop r> (lappend*) ]
		[ uncons r> cons lappend* cons ] if
	] unless ;

: lappend* ( llists -- list )
    #! Given a lazy list of lazy lists, concatenate them 
    #! together in a lazy fashion. The actual appending is 
    #! done lazily on iteration rather than immediately
    #! so it works very fast no matter how large the lists.
	[ , \ (lappend*) , ] force-promise ;

: lappend ( list1 list2 -- llist )
    #! Concatenate two lazy lists such that they appear to be one big
    #! lazy list.
    lunit cons lappend* ;

: leach ( list quot -- )
    #! Call the quotation on each item in the lazy list. 
    #! Warning: If the list is infinite then this will
    #! never return. 
	swap dup nil? [ 2drop ] [
		uncons swap pick call swap leach
	] if ;

DEFER: lapply	
: (lapply) ( list quot -- list )
	over nil? [ drop ] [ 
		swap dup car >r uncons pick call swap lapply
		r> swap cons 
	] if ;
	
: lapply ( list quot -- list )
    #! Returns a lazy list which is
	#! (cons (car list)
	#!		   (lapply (quot (car list) (cdr list)) quot))
	#! This allows for complicated list functions
    [ swap , , \ (lapply) , ] force-promise ;

DEFER: lfrom-by
: (lfrom-by) ( n quot -- list )
	2dup call swap lfrom-by cons ;
	
: lfrom-by ( n quot -- list )
    #! Return a lazy list of values starting from n, with
    #! each successive value being the result of applying quot to
    #! n.
    [ swap , , \ (lfrom-by) , ] force-promise ;
    
: lfrom ( n -- list )
	#! Return a lazy list of increasing numbers starting
	#! from the initial value 'n'.
	[ 1 + ] lfrom-by ;