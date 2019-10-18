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
USE: lists
USE: stack
USE: math
USE: stdio
USE: prettyprint
USE: kernel
USE: combinators
USE: logic

: curry1 ( n quot -- quot )
  #! Return a quotation that when called will initially
  #! have 'n' pushed on the stack.
  cons ;

: curry2 ( n1 n2 quot -- quot )
  #! Return a quotation that when called will initially
  #! have 'n1' and 'n2' pushed on the stack.
  cons cons ;

: delay ( value -- promise )
  #! Return a promise that when 'forced' returns the original value.
  unit ;

: force ( promise -- value )
  #! Return the value associated with the promise.
  call ;

: lcons ( car promise -- lcons )
  #! Return a lazy pair, where the cdr is a promise and must
  #! be forced to return the value.
  cons ;

: lunit ( a -- llist )
  #! Construct a lazy list of one element.
  [ ] delay lcons ;

: lcar ( lcons -- car )
  #! Return the car of a lazy pair.
  car ;

: lcdr ( lcons -- cdr )
  #! Return the cdr of a lazy pair, implicitly forcing it.
  cdr force ;

: lnth ( n llist -- value )
  #! Return the nth item in a lazy list
  swap [ lcdr ] times lcar ;

: luncons ( lcons -- car cdr )
  #! Return the car and forced cdr of the lazy cons.
  uncons force ;

: (ltake) ( n llist accum -- list )
  >r >r pred dup 0 < [ 
    drop r> drop r> nreverse  
  ] [ 
    r> luncons swap r> cons (ltake) 
  ] ifte ;

: ltake ( n llist -- list )
  #! Return a list containing the first n items from
  #! the lazy list.
  [ ] (ltake) ;

: lmap ( llist quot -- llist )
  #! Return a lazy list containing the collected result of calling
  #! quot on the original lazy list.
  over [ ] = [
    2drop [ ]
  ] [
    [ luncons ] dip     
    dup swapd           
    [ lmap ] curry2  
    [ call ] dip
    lcons 
  ] ifte ;

: lsubset ( llist pred -- llist )
  #! Return a lazy list containing only the items from the original
  #! lazy list for which the predicate returns a value other than f.
  over [ ] = [
    2drop [ ] 
  ] [
    [ luncons ] dip
    dup swapd
    [ lsubset ] curry2
    -rot dupd call [ 
      swap lcons
    ] [
      drop call 
    ] ifte 
  ] ifte ;

: lappend* ;
: (lappend*) ;
: lappend-list* ;

: lappend-item* ( llists list item -- llist )
  -rot [ lappend-list* ] curry2 lcons ;

: lappend-list* ( llists list -- llist )
  dup [ 
    #! non-empty list
    luncons swap lappend-item*
  ] [
    #! empty list
    drop lappend*
  ] ifte ;
  
  
: (lappend*) ( llists -- llist )
  dup lcar [  ( llists  ) 
    #! Yes, the first item in the list is a valid llist
    luncons swap lappend-list*
  ] [
    #! The first item in the list is an empty list.
    #! Resume passing the next list.
    lcdr lappend*
  ] ifte ;

: lappend* ( llists -- llist )
  #! Given a lazy list of lazy lists, return a lazy list that
  #! works through all of the sub-lists in sequence.
  dup [
    (lappend*)
  ] [
    #! Leave empty list on the stack
  ] ifte ;

: list>llist ( list -- llist )
  #! Convert a list to a lazy list.
  dup [
    uncons [ list>llist ] curry1 lcons 
  ] when ;

: lappend ( llist1 llist2 -- llist )
  #! Concatenate two lazy lists such that they appear to be one big lazy list.
  2list list>llist lappend* ;

: leach ( llist quot -- )
  #! Call the quotation on each item in the lazy list. 
  #! Warning: If the list is infinite then this will
  #! never return.  
  over [
      >r luncons r> tuck >r >r call r> r> leach
  ] [
      2drop
  ] ifte ;

