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
IN: continuations
USING: kernel io math prettyprint inspector lists arrays sequences namespaces ;

SYMBOL: mark
SYMBOL: mark-old

: set-mark ( cc -- )
  0 mark get set-nth ;

: get-mark ( -- cc )
  mark get first ;

: save-mark ( -- )
  get-mark mark-old set ;

: restore-mark ( -- )
  mark-old get set-mark ;

: with-mark ( quot -- )
  [ save-mark call restore-mark ] with-scope ;

: breset ( quot -- )
  #! Marks the boundary of the partial continuation.
  #! The quotation has stack effect ( r -- v ).
  [ 
    [ 1array dup mark set swap call mark get first continue-with ] with-scope 
  ] callcc1 nip ;

: (bshift) ( v r pcc -- )
  [
    swap mark set
    [
      [ set-mark continue-with ] callcc1 2nip 
    ] with-mark 
  ] with-scope ;

: bshift ( r quot -- )
  #! Calls the quotation with the partial continuation 
  #! on the stack. The quotation should have stack effect
  #! ( pcc -- v ). The partial continuation can be called
  #! with 'call' and has stack effect ( a -- b ). 
  [
    over mark set
    [ 
      [ (bshift) ] cons swapd cons swap call get-mark continue-with        
    ] callcc1 2nip 
  ] with-scope ;

