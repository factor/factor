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
USE: generic
USE: interpreter
USE: kernel
USE: lists
USE: math
USE: namespaces
USE: strings
USE: vectors
USE: words
USE: hashtables
USE: prettyprint

: with-dataflow ( param op [ in | out ] quot -- )
    #! Take input parameters, execute quotation, take output
    #! parameters, add node. The quotation is called with the
    #! stack effect.
    >r dup car dup list? [ [ drop object ] project ] unless ensure-d
    >r dataflow, r> r> rot
    [ pick car swap dataflow-inputs ] keep
    pick 2slip cdr dup cons? [ car ] when swap
    dataflow-outputs ; inline

: consume-d ( typelist -- )
    [ pop-d 2drop ] each ;

: produce-d ( typelist -- )
    [ <computed> push-d ] each ;

: (consume/produce) ( param op effect -- )
    [
        dup cdr list? [
            ( new style )
            unswons consume-d car produce-d
        ] [
            ( old style, will go away shortly )
            unswons [ pop-d drop ] times [ object <computed> push-d ] times
        ] ifte
    ] with-dataflow ;

: consume/produce ( word [ in-types out-types ] -- )
    #! Add a node to the dataflow graph that consumes and
    #! produces a number of values.
    #call swap (consume/produce) ;

: apply-effect ( word [ in-types out-types ] -- )
    #! If a word does not have special inference behavior, we
    #! either execute the word in the meta interpreter (if it is
    #! side-effect-free and all parameters are literal), or
    #! simply apply its stack effect to the meta-interpreter.
    over "infer" word-property dup [
        swap car dup list? [ [ drop object ] project ] unless ensure-d call drop
    ] [
        drop consume/produce
    ] ifte ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name cat2 throw ;

: with-recursive-state ( word label quot -- )
    >r
    <recursive-state> [ recursive-label set ] extend dupd cons
    recursive-state cons@
    r> call ;

: (with-block) ( label quot -- )
    #! Call a quotation in a new namespace, and transfer
    #! inference state from the outer scope.
    swap >r [
        dataflow-graph off
        call
        d-in get meta-d get meta-r get get-dataflow
    ] with-scope
    r> swap #label dataflow, [ node-label set ] bind
    meta-r set meta-d set d-in set ;

: with-block ( word label quot -- )
    #! Execute a quotation with the word on the stack, and add
    #! its dataflow contribution to a new block node in the IR.
    over [ with-recursive-state ] (with-block) ;

: inline-compound ( word -- effect )
    #! Infer the stack effect of a compound word in the current
    #! inferencer instance.
    gensym [ word-parameter infer-quot effect ] with-block ;

: (infer-compound) ( word -- effect )
    #! Infer a word's stack effect in a separate inferencer
    #! instance.
    [
        recursive-state get init-inference
        dup inline-compound
        [ "infer-effect" set-word-property ] keep
    ] with-scope ;

: infer-compound ( word -- )
    #! Infer the stack effect of a compound word in a separate
    #! inferencer instance, caching the result.
    [
        dup (infer-compound) consume/produce
    ] [
        [
            swap save-effect get [
                t "no-effect" set-word-property
            ] [
                drop
            ] ifte rethrow
        ] when*
    ] catch ;

: apply-compound ( word -- )
    #! Infer a compound word's stack effect.
    dup "inline" word-property [
        inline-compound drop
    ] [
        infer-compound
    ] ifte ;

: current-word ( -- word )
    #! Push word we're currently inferring effect of.
    recursive-state get car car ;

: no-base-case ( word -- )
    word-name " does not have a base case." cat2 throw ;

: check-recursion ( -- )
    #! If at the location of the recursive call, we're taking
    #! more items from the stack than producing, we have a
    #! diverging recursion.
    d-in get vector-length
    meta-d get vector-length > [
        current-word word-name " diverges." cat2 throw
    ] when ;

: recursive-word ( word state -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error. If the recursive
    #! call is to a local block, emit a label call node.
    base-case over hash dup [
        swap [ recursive-label get ] bind ( word effect label )
        dup [
            rot drop #call-label rot
        ] [
            drop #call swap
        ] ifte (consume/produce)
    ] [
        2drop no-base-case
    ] ifte ;

: no-effect? ( word -- ? )
    "no-effect" word-property ;

: apply-word ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup recursive-state get assoc dup [
        check-recursion recursive-word
    ] [
        drop dup "infer-effect" word-property dup [
            apply-effect
        ] [
            drop
            [
                [ no-effect? ] [ no-effect      ]
                [ compound?  ] [ apply-compound ]
                [ symbol?    ] [ apply-literal  ]
                [ drop t     ] [ no-effect      ]
            ] cond
        ] ifte
    ] ifte ;

: infer-call ( -- )
    [ general-list ] ensure-d
    dataflow-drop,
    gensym dup [
        drop pop-d dup
        value-recursion recursive-state set
        literal-value infer-quot
    ] with-block ;

\ call [ infer-call ] "infer" set-word-property

\ - [ 2 | 1 ] "infer-effect" set-word-property
\ * [ 2 | 1 ] "infer-effect" set-word-property
\ / [ 2 | 1 ] "infer-effect" set-word-property
\ gcd [ 2 | 1 ] "infer-effect" set-word-property
\ hashcode [ 1 | 1 ] "infer-effect" set-word-property
