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
USE: errors
USE: interpreter
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings
USE: vectors
USE: words
USE: hashtables
USE: generic
USE: prettyprint

! If this symbol is on, partial evalution of conditionals is
! disabled.
SYMBOL: inferring-base-case

! Word properties that affect inference:
! - infer-effect -- must be set. controls number of inputs
! expected, and number of outputs produced.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Vector of results we had to add to the datastack. Ie, the
! inputs.
SYMBOL: d-in

! Recursive state. An alist, mapping words to labels.
SYMBOL: recursive-state

GENERIC: literal-value ( value -- obj )
GENERIC: value= ( literal value -- ? )
GENERIC: value-class ( value -- class )
GENERIC: value-class-and ( class value -- )
GENERIC: set-value-class ( class value -- )

! A value has the following slots in addition to those relating
! to generics above:

! An association list mapping values to [ value | class ] pairs
SYMBOL: type-propagations

TRAITS: computed
C: computed ( class -- value )
    [
        \ value-class set
        gensym \ literal-value set
        type-propagations off
    ] extend ;
M: computed literal-value ( value -- obj )
    "Cannot use a computed value literally." throw ;
M: computed value= ( literal value -- ? )
    2drop f ;
M: computed value-class ( value -- class )
    [ \ value-class get ] bind ;
M: computed value-class-and ( class value -- )
    [ \ value-class [ class-and ] change ] bind ;
M: computed set-value-class ( class value -- )
    [ \ value-class set ] bind ;

TRAITS: literal
C: literal ( obj rstate -- value )
    [
        recursive-state set
        \ literal-value set
        type-propagations off
    ] extend ;
M: literal literal-value ( value -- obj )
    [ \ literal-value get ] bind ;
M: literal value= ( literal value -- ? )
    literal-value = ;
M: literal value-class ( value -- class )
    literal-value class ;
M: literal value-class-and ( class value -- )
    value-class class-and drop ;
M: literal set-value-class ( class value -- )
    2drop ;

: value-recursion ( value -- rstate )
    [ recursive-state get ] bind ;

: (ensure-types) ( typelist n stack -- )
    pick [
        3dup >r >r car r> r> vector-nth value-class-and
        >r >r cdr r> 1 + r> (ensure-types)
    ] [
        3drop
    ] ifte ;

: ensure-types ( typelist stack -- )
    dup vector-length pick length - dup 0 < [
        swap >r neg tail 0 r>
    ] [
        swap
    ] ifte (ensure-types) ;

: required-inputs ( typelist stack -- values )
    >r dup length r> vector-length - dup 0 > [
        head [ <computed> ] map
    ] [
        2drop f
    ] ifte ;

: vector-prepend ( values stack -- stack )
    >r list>vector dup r> vector-append ;

: ensure-d ( typelist -- )
    dup meta-d get ensure-types
    meta-d get required-inputs dup
    meta-d [ vector-prepend ] change
    d-in [ vector-prepend ] change ;

: effect ( -- [ in-types out-types ] )
    #! After inference is finished, collect information.
    d-in get [ value-class ] vector-map vector>list
    meta-d get [ value-class ] vector-map vector>list 2list ;

: init-inference ( recursive-state -- )
    init-interpreter
    0 <vector> d-in set
    recursive-state set
    dataflow-graph off
    inferring-base-case off ;

DEFER: apply-word

: apply-literal ( obj -- )
    #! Literals are annotated with the current recursive
    #! state.
    dup recursive-state get <literal> push-d
    #push dataflow, [ 1 0 node-outputs ] bind ;

: apply-object ( obj -- )
    #! Apply the object's stack effect to the inferencer state.
    dup word? [ apply-word ] [ apply-literal ] ifte ;

: infer-quot ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ apply-object ] each ;

: check-return ( -- )
    #! Raise an error if word leaves values on return stack.
    meta-r get vector-length 0 = [
        "Word leaves elements on return stack" throw
    ] unless ;

: values-node ( op -- )
    #! Add a #values or #return node to the graph.
    f swap dataflow, [
        meta-d get vector>list node-consume-d set
    ] bind ;

: (infer) ( quot -- )
    f init-inference
    infer-quot
    #return values-node check-return ;

: infer ( quot -- [ in | out ] )
    #! Stack effect of a quotation.
    [ (infer) effect ] with-scope ;

: dataflow ( quot -- dataflow )
    #! Data flow of a quotation.
    [ (infer) get-dataflow ] with-scope ;
