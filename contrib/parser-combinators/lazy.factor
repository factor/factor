! Updated by Matthew Willis, July 2006
!
! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

USING: kernel sequences math vectors arrays namespaces ;
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

: nil ( -- list )
    #! The nil lazy list.
    T{ promise f [ { } ] t { } } ;

: nil? ( list -- bool )
    #! Is the given lazy cons the nil value
    force { } = ;

: car ( list -- car )
    #! Return the value of the head of the lazy list. 
    force cons-car ;

: cdr ( list -- cdr )
    #! Return the rest of the lazy list.
    #! This is itself a lazy list.
    force cons-cdr ;

: cons ( car cdr -- list )
    #! Given a car and cdr, both lazy values, return a lazy cons.
    [ swap , , \ <cons> , ] [ ] make <promise> ;

: lunit ( obj -- list )
    #! Given a value produce a lazy list containing that value.
    nil cons ;

: lnth ( n list -- value )
    #! Return the nth item in a lazy list
    swap [ cdr ] times car ;

: uncons ( cons -- car cdr )
    #! Return the car and cdr of the lazy list
    force dup cons-car swap cons-cdr ;
    
: force-promise ( list-quot -- list )
    #! Promises to force list-quot, which should be
    #! a quot that produces a list.
    #! This allows caching of the resultant list value.
    [ call \ force , ] [ ] make <promise> ; inline

DEFER: lmap
: (lmap) ( list quot -- list )
	over nil? [ drop ] 
	[
  	    swap 2dup
  	    cdr swap lmap >r
        car swap call r> 
  	    cons
	] if ;

: lmap ( list quot -- list )
    #! Return a lazy list containing the collected result of calling
    #! quot on the original lazy list.
    [ swap , , \ (lmap) ,  ] force-promise ;

DEFER: ltake
: (ltake) ( n list -- list )
    over 0 = [ 2drop nil ] 
	[ dup nil? [ nip ] 
		[
            swap  ( list n -- list )
            1 - >r uncons r> swap ltake 
            cons
  	    ] if 
	] if ;

: ltake ( n list -- list )
    #! Return a lazy list containing the first n items from
    #! the original lazy list.
    [ swap , , \ (ltake) , ] force-promise ;

DEFER: lsubset
: (lsubset) ( list pred -- list )
	>r dup nil? [ r> drop ] 
	[
		uncons swap dup r> dup >r call 
		[ swap r> lsubset cons ] 
		[ drop r> (lsubset) ] if
	] if ;
	
: lsubset ( list pred -- list )
    #! Return a lazy list containing the elements in llist 
    #! satisfying pred	
	[ swap , , \ (lsubset) , ] force-promise ;

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