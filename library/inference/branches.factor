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

: vector-length< ( vec1 vec2 -- ? )
    swap vector-length swap vector-length < ;

: unify-length ( vec1 vec2 -- vec1 )
    2dup vector-length< [ swap ] unless [
        vector-length over vector-length -
        empty-vector [ swap vector-append ] keep
    ] keep ;

: unify-classes ( value value -- class )
    #! If one of the values is f, it was added as a result of
    #! length unification so we just replace it with a computed
    #! object value.
    2dup and [
        value-class swap value-class class-or
    ] [
        2drop object
    ] ifte ;

: unify-results ( value value -- value )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ unify-classes <computed> ] ifte ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    uncons [
        unify-length vector-zip [
            uncons unify-results
        ] vector-map
    ] each ;

: balanced? ( list -- ? )
    #! Check if a list of [ instack | outstack ] pairs is
    #! balanced.
    [ uncons vector-length swap vector-length - ] map all=? ;

: unify-effect ( list -- in out )
    #! Unify a list of [ instack | outstack ] pairs.
    dup balanced? [
        unzip unify-stacks >r unify-stacks r>
    ] [
        "Unbalanced branches" throw
    ] ifte ;

: datastack-effect ( list -- )
    [ [ d-in get meta-d get ] bind cons ] map
    unify-effect
    meta-d set d-in set ;

: callstack-effect ( list -- )
    [ [ { } meta-r get ] bind cons ] map
    unify-effect
    meta-r set drop ;

: filter-terminators ( list -- list )
    [ [ d-in get meta-d get and ] bind ] subset [
        "No branch has a stack effect" throw
    ] unless* ;

: unify-effects ( list -- )
    filter-terminators  dup datastack-effect callstack-effect ;

: deep-clone ( vector -- vector )
    #! Clone a vector of vectors.
    [ vector-clone ] vector-map ;

: infer-branch ( value save-effect -- namespace )
    <namespace> [
        save-effect set
        dup value-recursion recursive-state set
        meta-r [ deep-clone ] change
        meta-d [ deep-clone ] change
        d-in [ deep-clone ] change
        dataflow-graph off
        literal-value infer-quot
        #values values-node
    ] extend ;

: terminator? ( obj -- ? )
    dup word? [ "terminator" word-property ] [ drop f ] ifte ;

: terminator-quot? ( quot -- ? )
    literal-value [ terminator? ] some? ;

: dual-branch ( branchlist branch -- rstate )
    #! Return a recursive state for a branch other than the
    #! given one in the list.
    swap [ over eq? not ] subset nip car value-recursion ;

SYMBOL: dual-recursive-state

: recursive-branch ( branchlist value -- namespace )
    #! Return effect namespace if inference didn't fail.
    [
        [ dual-branch dual-recursive-state set ] keep
        f infer-branch
    ] [
        [ 2drop f ] when
    ] catch ;

: infer-base-cases ( branchlist -- list )
    dup [ dupd recursive-branch ] map [ ] subset nip ;

: infer-base-case ( branchlist -- )
    #! Can't do much if there is only one non-terminator branch.
    #! Either the word is not recursive, or it is recursive
    #! and the base case throws an error.
    [
        [ terminator-quot? not ] subset dup length 1 > [
            infer-base-cases unify-effects
            effect dual-recursive-state get set-base
        ] [
            drop
        ] ifte
    ] with-scope ;

: (infer-branches) ( branchlist -- list )
    dup infer-base-case [
        dup t infer-branch swap terminator-quot? [
            [ meta-d off meta-r off d-in off ] extend
        ] when
    ] map ;

: unify-dataflow ( inputs instruction effectlist -- )
    [ [ get-dataflow ] bind ] map
    swap dataflow, [ node-consume-d set ] bind ;

: infer-branches ( inputs instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again. The inputs
    #! parameter is a vector.
    (infer-branches) dup unify-effects unify-dataflow ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    [ object general-list general-list ] ensure-d
    dataflow-drop, pop-d
    dataflow-drop, pop-d swap 2list
    >r 1 meta-d get vector-tail* #ifte r>
    pop-d drop ( condition )
    infer-branches ;

\ ifte [ infer-ifte ] "infer" set-word-property

: vtable>list ( value -- list )
    dup value-recursion swap literal-value vector>list
    [ over <literal> ] map nip ;

: infer-dispatch ( -- )
    #! Infer effects for all branches, unify.
    [ object vector ] ensure-d
    dataflow-drop, pop-d vtable>list
    >r 1 meta-d get vector-tail* #dispatch r>
    pop-d drop ( n )
    infer-branches ;

USE: kernel-internals
\ dispatch [ infer-dispatch ] "infer" set-word-property
\ dispatch [ [ fixnum vector ] [ ] ]
"infer-effect" set-word-property
