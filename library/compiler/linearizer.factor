! :folding=indent:collapseFolds=1:

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

IN: linearizer
USE: lists
USE: words
USE: stack
USE: namespaces
USE: dataflow
USE: combinators

! Linear IR nodes. This is in addition to the symbols already
! defined in dataflow vocab.

SYMBOL: #branch-t ( branch if top of stack is true )
SYMBOL: #branch ( unconditional branch )
SYMBOL: #label ( branch target )
SYMBOL: #jump ( tail-call )
SYMBOL: #return ( return to caller )

: linear, ( param op -- )
    swons , ;

: >linear ( node -- )
    #! Dataflow OPs have a linearizer word property. This
    #! quotation is executed to convert the node into linear
    #! form.
    [ node-param get  node-op get ] bind
    dup "linearizer" word-property dup [
        nip call
    ] [
        drop linear,
    ] ifte ;

: (linearize) ( dataflow -- )
    [ >linear ] each ;

: linearize ( dataflow -- linear )
    #! Transform dataflow IR into linear IR. This strips out
    #! stack flow information, flattens conditionals into
    #! jumps and labels, and turns dataflow IR nodes into
    #! lists where the first element is an operation, and the
    #! rest is arguments.
    [ (linearize)  f #return linear, ] make-list ;

: <label> ( -- label )
    gensym ;

: label, ( label -- )
    #label linear, ;

: linearize-ifte ( param -- )
    #! The parameter is a list of two lists, each one a dataflow
    #! IR.
    uncons car
    <label> [
        #branch-t linear,
        (linearize) ( false branch )
        <label> dup #branch linear,
    ] keep label, ( branch target of BRANCH-T )
    swap (linearize) ( true branch )
    label, ( branch target of false branch end ) ;

\ #ifte [ linearize-ifte ] "linearizer" set-word-property
