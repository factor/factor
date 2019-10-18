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
USE: lists
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

: force ( <promise> -- value )
  (force) dup promise? [
    force
  ] when ;
  
TUPLE: lcons car cdr ;

SYMBOL: lazy-nil
DEFER: lnil
[ [ ] ] delay  lazy-nil set

: lnil ( -- lcons )
  #! Return the nil lazy list.
  lazy-nil get ;

: lnil? ( lcons -- bool )
  #! Is the given lazy cons the nil value
  force not ;

: lcar ( lcons -- car )
  #! Return the value of the head of the lazy list.
  dup lnil? [ 
    force lcons-car (force) 
  ] unless ;

: lcdr ( lcons -- cdr )
  #! Return the value of the rest of the lazy list.
  #! This is itself a lazy list.
  dup lnil? [
    force lcons-cdr (force) 
  ] unless ;

: lcons ( lcar lcdr -- promise )
  #! Given a car and cdr, both lazy values, return a lazy cons.
  swap [ , , \ <lcons> , ] [ ] make delay ;

: lunit ( lvalue -- llist )
  #! Given a lazy value (a quotation that when called produces
  #! the value) produce a lazy list containing that value.
  [ lnil ] delay lcons ;

: lnth ( n llist -- value )
  #! Return the nth item in a lazy list
  swap [ lcdr ] times lcar ;

: luncons ( lcons -- car cdr )
  #! Return the car and cdr of the lazy list
  dup lcar swap lcdr ;

: lmap ( llist quot -- llist )
  #! Return a lazy list containing the collected result of calling
  #! quot on the original lazy list.
  over lnil? [
    drop
  ] [
    swap 2dup
    [ , \ lcdr , , \ lmap , ] [ ] make delay >r
    [ , \ lcar , , \ call , ] [ ] make delay r> 
    lcons 
  ] if ;

: ltake ( n llist -- llist )
  #! Return a lazy list containing the first n items from
  #! the original lazy list.
  over 0 = [
    2drop lnil 
  ] [
    dup lnil? [
      nip
    ] [
        swap dupd     ( llist llist n  -- )
        [ [ 1 - ] cons , \ call , , \ lcdr , \ ltake , ] [ ] make delay >r
        [ , \ lcar , ] [ ] make delay r> 
        lcons 
    ] if 
  ] if ;

DEFER: lsubset
TUPLE: lsubset-state llist pred ;

: (lsubset-cdr) ( state -- llist )
  #! Given a predicate and a lazy list, do the cdr
  #! portion of lsubset.
  dup lsubset-state-llist lcdr swap lsubset-state-pred lsubset ;

: (lsubset-car) ( state -- value )
  #! Given a predicate and a lazy list, do the car
  #! portion of lsubset.
  dup lsubset-state-llist lcar over 
  lsubset-state-pred dupd call [ ( state lcar -- )
    nip
  ] [ ( state lcar -- )
    drop dup lsubset-state-llist lcdr over set-lsubset-state-llist
    (lsubset-car)
  ] if ;

: (lsubset-set-first-car) ( state -- bool )
  #! Set the state to the first valid car. If none found
  #! return false.
  dup lsubset-state-llist lcar over 
  lsubset-state-pred dupd call [ ( state lcar -- )
    2drop t 
  ] [ ( state lcar -- )
    drop dup lsubset-state-llist lcdr dup lnil? [
      2drop f
    ] [
      over set-lsubset-state-llist
      (lsubset-set-first-car)
    ] if
  ] if ;

: lsubset ( llist pred -- llist )
  #! Return a lazy list containing only the items from the original
  #! lazy list for which the predicate returns a value other than f.
  over lnil? [ 
    drop
  ] [
    <lsubset-state> dup
    (lsubset-set-first-car) [
      dup
      [ (lsubset-cdr) ] cons delay >r 
      [ (lsubset-car) ] cons delay r> lcons
    ] [
      drop lnil
    ] if
  ] if ;

DEFER: lappend*
DEFER: (lappend*)
TUPLE: lappend*-state current rest ;

USE: io 

: (lappend*-cdr) ( state -- llist )
  #! Given the state object, do the cdr portion of the
  #! lazy append.
  dup lappend*-state-current dup lnil? [ ( state current -- )
    nip
  ] [ ( state current -- )
    lcdr ( state cdr -- )
    dup lnil? [ ( state cdr -- ) 
      drop dup lappend*-state-rest dup lnil? [ ( state rest )
        nip
      ] [
        nip
        luncons ( state rest-car rest-cdr -- )
        <lappend*-state> (lappend*)
      ] if 
    ] [ ( state cdr -- )
      swap lappend*-state-rest <lappend*-state> (lappend*)
    ] if 
  ] if ;

: (lappend*-car) ( state -- value )
  #! Given the state object, do the car portion of the 
  #! lazy append.
  dup lappend*-state-current dup lnil? [ ( state current -- )
    nip
  ] [ ( state current -- )
    lcar nip
  ] if ;

: (lappend*) ( state -- llist )
  #! Do the main work of the lazy list appending using a
  #! state object.
  dup 
  [ (lappend*-cdr) ] cons delay >r
  [ (lappend*-car) ] cons delay r> lcons ;    

: lappend* ( llists -- llist )
  #! Given a lazy list of lazy lists, return a lazy list that
  #! works through all of the sub-lists in sequence.
  [ lnil? not ] lsubset
  dup lnil? [
    luncons <lappend*-state> (lappend*)
  ] unless ;

DEFER: list>llist

: lappend ( llist1 llist2 -- llist )
  #! Concatenate two lazy lists such that they appear to be one big
  #! lazy list.
  2list list>llist lappend* ;

: leach ( llist quot -- )
  #! Call the quotation on each item in the lazy list. 
  #! Warning: If the list is infinite then this will
  #! never return.  
  over lnil? [
      2drop
  ] [
      >r luncons r> tuck >r >r call r> r> leach
  ] if ;


: (llist>list) ( result llist -- list )
  #! Helper function for llist>list.
  dup lnil? [
    drop
  ] [
    dup lcar ( result llist car )
    swap lcdr >r swons r> (llist>list)  
  ] if ;

: llist>list ( llist -- list )
  #! Convert a lazy list to a normal list. This will cause
  #! an infinite loop if the lazy list is an infinite list.
  f swap (llist>list) reverse ;

: list>llist ( list -- llist )
  #! Convert a list to a lazy list.
  dup [
    uncons [ list>llist ] cons delay >r unit delay r> lcons 
  ] [ 
    drop lnil
  ] if ;

! M: lcons nth lnth ;

: test1 
  [ 1 ] list>llist
  [ 2 ] list>llist
  2list
  list>llist
  lappend* ;

: test2 
  [ 1 2 ] list>llist
  [ 3 4 ] list>llist
  2list
  list>llist
  lappend* ;

: test3
  [ 1 2 3 ] list>llist
  [ 4 5 6 ] list>llist
  [ 7 8 9 ] list>llist
  2list cons
  list>llist
  lappend* ;

: test4
  [ 1 2 3 4 5 ] list>llist
  [ 2 mod 1 = ] lsubset ;

: test5 lnil unit delay lunit [ lnil? not ] lsubset ;

: test6 lnil unit delay lunit lappend* ;

