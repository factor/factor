! Copyright (C) 2005 Chris Double.
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
!
IN: coroutines
USING: kernel generic ;

TUPLE: coroutine resumecc exitcc ;

: cocreate ( quot - co )
  #! Create a new coroutine, which will execute the quotation
  #! when resumed. The quotation will have the coroutine
  #! on the stack and an initial value (received from coresume)
  #! when first resumed. ie. The quotation should have stack
  #! effect ( co value -- ).
  f f <coroutine> dup rot curry over set-coroutine-resumecc ;

: coresume ( v co -- result )
  #! Resume a coroutine with 'v' as the first item on the
  #! stack. The result placed on the stack is that of the 
  #! topmost argument on the stack when coyield is called
  #! within the coroutine.
  [ 
    over set-coroutine-exitcc
    coroutine-resumecc call
  ] callcc1 rot drop ;

: coyield ( v co -- result )
  #! Suspend a coroutine, leaving the value 'v' on the 
  #! stack when control is passed to the 'coresume' caller.
  [  
    [ continue-with ] curry
    over set-coroutine-resumecc  
    coroutine-exitcc continue-with
  ] callcc1 rot drop ;

USE: prettyprint
USE: sequences

: test1 ( list -- co )
  [ swap [ over coyield 2drop ] each f swap coyield ] cocreate ; 
  
: test2 ( -- co )
  [ 1 over coyield drop 2 over coyield drop 3 over coyield ] cocreate ;

test2 f swap coresume . f swap coresume . f swap coresume . drop

: test3 ( -- co )
  [ [ 1 2 3 ] [ over coyield drop ] each ] cocreate ;

test3 f swap coresume . f swap coresume . f swap coresume . drop

PROVIDE: coroutines ;

