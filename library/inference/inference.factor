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

IN: inference
USE: combinators
USE: errors
USE: interpreter
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: stack
USE: strings
USE: vectors
USE: words
USE: hashtables

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Amount of results we had to add to the datastack
SYMBOL: d-in

! Recursive state. Alist maps words to hashmaps...
SYMBOL: recursive-state
! ... with keys:
SYMBOL: base-case
SYMBOL: entry-effect
! When a call to a combinator is compiled, recursion cannot
! simply jump to the definition of the combinator. Instead, it
! makes a local jump to this label.
SYMBOL: recursive-label

: gensym-vector ( n --  vector )
    dup <vector> swap [ gensym over vector-push ] times ;

: add-inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    >r gensym-vector dup r> vector-append ;

: ensure ( count stack -- count stack )
    #! Ensure stack has this many elements. Return number of
    #! elements added.
    2dup vector-length > [
        [ vector-length - dup ] keep add-inputs
    ] [
        >r drop 0 r>
    ] ifte ;

: ensure-d ( count -- )
    #! Ensure count of unknown results are on the stack.
    meta-d [ ensure ] change d-in +@ ;

: consume-d ( count -- )
    #! Remove count of elements.
    [ pop-d drop ] times ;

: produce-d ( count -- )
    #! Push count of unknown results.
    [ gensym push-d ] times ;

: effect ( -- [ in | out ] )
    #! After inference is finished, collect information.
    d-in get  meta-d get vector-length cons ;

: <recursive-state> ( -- state )
    <namespace> [
        base-case off  effect entry-effect set
    ] extend ;

: init-inference ( recursive-state -- )
    init-interpreter
    0 d-in set
    recursive-state set
    dataflow-graph off ;

DEFER: apply-word

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    dup recursive-state get cons push-d
    #push dataflow, [ 1 0 node-outputs ] bind ;

: apply-object ( obj -- )
    #! Apply the object's stack effect to the inferencer state.
    dup word? [ apply-word ] [ apply-literal ] ifte ;

: infer-quot ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ apply-object ] each ;

: compose ( first second -- total )
    #! Stack effect composition.
    >r uncons r> uncons >r -
    dup 0 < [ neg + r> cons ] [ r> + cons ] ifte ;

: raise ( [ in | out ] -- [ in | out ] )
    uncons 2dup min tuck - >r - r> cons ;

: decompose ( first second -- solution )
    #! Return a stack effect such that first*solution = second.
    2dup 2car
    2dup > [ "No solution to decomposition" throw ] when
    swap - -rot 2cdr >r + r> cons raise ;

: set-base ( [ in | stack ] rstate -- )
    #! Set the base case of the current word.
    dup [
        >r uncons vector-length cons r>  car cdr [
            entry-effect get swap decompose base-case set
        ] bind
    ] [
        2drop
    ] ifte ;

: return-node ( -- )
    #! Add a #return node to the dataflow graph.
    f #return dataflow, [
        meta-d get vector>list node-consume-d set
        meta-r get vector-length 0 = [
            "Word leaves elements on return stack" throw
        ] unless
    ] bind ;

: (infer) ( quot -- )
    f init-inference infer-quot return-node ;

: infer ( quot -- [ in | out ] )
    #! Stack effect of a quotation.
    [ (infer) effect ] with-scope ;

: try-infer ( quot -- effect/f )
    #! Push f if inference fails.
    [ infer ] [ [ drop f ] when ] catch ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (infer) get-dataflow ] with-scope ;
