!:folding=indent:collapseFolds=1:

! $Id$
!
! Copyright (C) 2004 Slava Pestov.
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

IN: errors
USE: arithmetic
USE: combinators
USE: continuations
USE: kernel
USE: lists
USE: namespaces
USE: stack
USE: strings
USE: vectors

: >c ( catch -- )
    #! Push a catch block on the catchstack. Use the catch word
    #! instead of invoking this word directly.
    catchstack* vector-push ;

: c> ( catch -- )
    #! Pop a catch block from the catchstack. Use the catch word
    #! instead of invoking this word directly.
    catchstack* vector-pop ;

: >pop> ( stack -- stack )
    dup vector-pop drop ;

: save-error ( error -- )
    #! Save the stacks for most-mortem inspection after an
    #! error.
    global [
        "error" set
        datastack >pop> "error-datastack" set
        callstack >pop> >pop> "error-callstack" set
        namestack "error-namestack" set
        catchstack "error-catchstack" set
    ] bind ;

: catch ( try catch -- )
    #! Call the try quotation, restore the datastack to its
    #! state before the try quotation, push the error (or f if
    #! no error occurred) and call the catch quotation.
    [ >c drop call f c> call ] callcc1 ( c> drop )
    ( try catch error ) rot drop swap ( error catch ) call ;

: rethrow ( error -- )
    #! Use rethrow when passing an error on from a catch block.
    #! For convinience, this word is a no-op if error is f.
    [ c> call ] when* ;

: throw ( error -- )
    #! Throw an error. If no catch handlers are installed, the
    #! default-error-handler is called.
    dup save-error rethrow ;
