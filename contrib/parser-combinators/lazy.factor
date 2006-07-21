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
IN: lazy
USE: kernel
USE: sequences
USE: namespaces
USE: math

TUPLE: promise quot forced? value ;

: delay ( quot -- <promise> )
  #! Given a quotation, create a promise which may later be forced.
  #! When forced the quotation will execute returning the value. Future
  #! forces of the promise will return that value and not re-execute
  #! the quotation.
  f f <promise> ;

: (force) ( <promise> -- value )
  #! Force the given promise leaving the value of calling the
  #! promises quotation on the stack. Re-forcing the promise
  #! will return the same value and not recall the quotation.
  dup promise-forced? [
    dup promise-quot call over set-promise-value
    t over set-promise-forced?
  ] unless
  promise-value ;
  
TUPLE: lcons car cdr ;

SYMBOL: lazy-nil
[ [ ] ] delay lazy-nil set

: lnil ( -- llist )
  #! Return the nil lazy list.
  lazy-nil get ;

: lnil? ( llist -- bool )
  #! Is the given lazy cons the nil value
  (force) dup quotation? [ empty? ] [ drop f ] if ;

: lcar ( llist -- car )
  #! Return the value of the head of the lazy list. 
  (force) lcons-car ;

: lcdr ( llist -- cdr )
  #! Return the rest of the lazy list.
  #! This is itself a lazy list.
  (force) lcons-cdr ;

: lcons ( lcar lcdr -- llist )
  #! Given a car and cdr, both lazy values, return a lazy cons.
  [ <lcons> ] curry curry delay ;

: lunit ( lvalue -- llist )
  #! Given a lazy value (a quotation that when called produces
  #! the value) produce a lazy list containing that value.
  lnil lcons ;

: lnth ( n llist -- value )
  #! Return the nth item in a lazy list
  swap [ lcdr ] times lcar ;

: luncons ( lcons -- car cdr )
  #! Return the car and cdr of the lazy list
  dup lcar swap lcdr ;

DEFER: lmap
: (lmap) ( llist quot -- list )
	over lnil? [ drop ] 
	[
  	swap 2dup
  	lcdr swap lmap >r
  	lcar swap call r> 
  	lcons
	] if ;

: lmap ( llist quot -- llist )
  #! Return a lazy list containing the collected result of calling
  #! quot on the original lazy list.
  [ (lmap) (force) ] curry curry delay ;

DEFER: ltake
: (ltake) ( n llist -- llist )
  over 0 = [ 2drop lnil ] 
	[ dup lnil? [ nip	] 
		[
      swap  ( llist n -- )
      1 - >r luncons r> swap ltake 
      lcons
  	] if 
	] if ;

: ltake ( n llist -- llist )
  #! Return a lazy list containing the first n items from
  #! the original lazy list.
  [ (ltake) (force) ] curry curry delay ;

DEFER: lsubset
: (lsubset) ( llist pred -- llist )
	>r dup lnil? [ r> drop ] 
	[
		luncons swap dup r> dup >r call 
		[ swap r> lsubset lcons ] 
		[ drop r> (lsubset) ] if
	] if ;
	
: lsubset ( llist pred -- llist )
  #! Return a lazy list containing the elements in llist 
  #! satisfying pred	
	[ (lsubset) (force) ] curry curry delay ;

: llist>list ( llist -- list )
  #! Convert a lazy list to a normal list. This will cause
  #! an infinite loop if the lazy list is an infinite list.
  dup lnil? [ drop [ ] ]
	[ luncons llist>list curry ] if ;

DEFER: list>llist
: (list>llist) ( list -- llist )
  dup empty? [ drop lnil ]
	[ dup first 0 rot remove-nth list>llist lcons ] if ;

: list>llist ( list -- llist )
  #! Convert a list to a lazy list.
  [ (list>llist) (force) ] curry delay ;

DEFER: lappend*
: (lappend*) ( llists -- list )
	dup lnil? [ 
		luncons >r dup lnil? [ drop r> (lappend*) ]
		[ luncons r> lcons lappend* lcons ] if
	] unless ;

: lappend* ( llists -- list )
  #! Given a lazy list of lazy lists, concatenate them 
  #! together in a lazy fashion. The actual appending is 
  #! done lazily on iteration rather than immediately
  #! so it works very fast no matter how large the lists.
	[ (lappend*) (force) ] curry delay ;

: lappend ( llist1 llist2 -- llist )
  #! Concatenate two lazy lists such that they appear to be one big
  #! lazy list.
  lunit lcons lappend* ;

: leach ( llist quot -- )
  #! Call the quotation on each item in the lazy list. 
  #! Warning: If the list is infinite then this will
  #! never return. 
	swap dup lnil? [ 2drop ] [
		luncons swap pick call swap leach
	] if ;
	
: lapply ( llist quot )
	#! Returns a lazy list which is
	#! (cons (car llist)
	#!		   (lappy (quot (car llist) (cdr llist)) quot))
	#! This allows for complicated list functions
	[ over lnil? [ drop ] [ 
			swap dup lcar >r luncons pick call swap lapply
			r> swap lcons 
		] if (force) 
	] curry curry delay ;
	
: lfrom ( n -- llist )
	#! Return a lazy list of increasing numbers starting
	#! from the initial value 'n'.
	[ dup 1 + lfrom lcons (force) ] curry delay ;

: lfrom-by ( n quot -- llist )
	#! Return a lazy list of values starting from n, with
	#! each successive value being the result of applying quot to
	#! n.
	[ 2dup call swap lfrom-by lcons (force) ] curry curry delay ;
