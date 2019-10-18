! Copyright (C) 2006 Chris Double.
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
! Based on Scheme code for bshift and breset from:
! http://groups.google.com/group/comp.lang.scheme/msg/9f0d61da01540816
!
! See this blog entry for more details:
! http://www.bluishcoder.co.nz/2006/03/factor-partial-continuation-updates.html
!
IN: continuations
USING: kernel io math prettyprint inspector lists arrays sequences namespaces ;

: breset ( quot -- )
  #! Marks the boundary of the partial continuation.
  #! The quotation has stack effect ( r -- v ), where
  #! 'r' identifies the breset in scope and should be passed
  #! to bshift to mark the boundary of the continuation.
  #! It is important to note that even if the quotation
  #! discards items on the stack, the stack will be restored to
  #! the way it was before it is called (which is true of callcc
  #! usage in general).
  [ 1array swap keep first continue-with ] callcc1 nip ;

: (bshift) ( v r k -- )
  >r dup first -rot r> ( old-rc v r k )
  [  ( old-rc v r k kstar  )
    rot 0 swap set-nth ( old-rc v k )
    continue-with  
  ] callcc1 ( old-rc v r k v2 )
  >r drop nip 0 swap set-nth r> ;

: bshift ( r quot -- )
  #! Calls the quotation with the partial continuation 
  #! on the stack. The quotation should have stack effect
  #! ( pcc -- v ). The partial continuation can be called
  #! with 'call' and has stack effect ( a -- b ). 
  #! It is important to note that even if the quotation
  #! discards items on the stack, the stack will be restored to
  #! the way it was before it is called (which is true of callcc
  #! usage in general).
  [ ( r quot k )
    [ (bshift) ] cons pick  swons swap ( r bshift quot )
    rot >r call ( v )
    r> first continue-with        
  ] callcc1 2nip ;

