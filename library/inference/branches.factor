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
    2dup = [
        drop
    ] [
        unify-classes <computed>
    ] ifte ;

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

SYMBOL: cloned

: deep-clone ( vector -- vector )
    #! Clone a vector if it hasn't already been cloned in this
    #! with-deep-clone scope.
    dup cloned get assoc dup [
        nip
    ] [
        drop vector-clone [ dup cloned [ acons ] change ] keep
    ] ifte ;

: deep-clone-vector ( vector -- vector )
    #! Clone a vector of vectors.
    [ deep-clone ] vector-map ;

: copy-inference ( -- )
    #! We avoid cloning the same object more than once in order
    #! to preserve identity structure.
    cloned off
    meta-r [ deep-clone-vector ] change
    meta-d [ deep-clone-vector ] change
    d-in [ deep-clone-vector ] change
    dataflow-graph off ;

: terminator? ( obj -- ? )
    dup word? [ "terminator" word-property ] [ drop f ] ifte ;

: handle-terminator ( quot -- )
    [ terminator? ] some? [
        meta-d off meta-r off d-in off
    ] when ;

: infer-branch ( value -- namespace )
    <namespace> [
        uncons [ unswons set-value-class ] when*
        dup value-recursion recursive-state set
        copy-inference
        literal-value dup infer-quot
        #values values-node
        handle-terminator
    ] extend ;

: (infer-branches) ( branchlist -- list )
    #! The branchlist is a list of pairs:
    #! [ value | typeprop ]
    #! value is either a literal or computed instance; typeprop
    #! is a pair [ value | class ] indicating a type propagation
    #! for the given branch.
    [
        [
            inferring-base-case get [
                [
                    infer-branch ,
                ] [
                    [ drop ] when
                ] catch
            ] [
                infer-branch ,
            ] ifte
        ] each
    ] make-list ;

: unify-dataflow ( inputs instruction effectlist -- )
    [ [ get-dataflow ] bind ] map
    swap dataflow, [ node-consume-d set ] bind ;

: infer-branches ( inputs instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again. The inputs
    #! parameter is a vector.
    (infer-branches)  dup unify-effects unify-dataflow ;

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

: static-branch? ( value -- )
    literal? inferring-base-case get not and ;

: static-ifte ( true false -- )
    #! If the branch taken is statically known, just infer
    #! along that branch.
    dataflow-drop, pop-d literal-value [ drop ] [ nip ] ifte
    gensym [
        dup value-recursion recursive-state set
        literal-value infer-quot
    ] (with-block) ;

: dynamic-ifte ( true false -- )
    #! If branch taken is computed, infer along both paths and
    #! unify.
    2list >r 1 meta-d get vector-tail* #ifte r>
    pop-d [
        dup \ object cons ,
        \ f cons ,
    ] make-list zip ( condition )
    infer-branches ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    [ object general-list general-list ] ensure-d
    dataflow-drop, pop-d
    dataflow-drop, pop-d swap
!    peek-d static-branch? [
!        static-ifte
!    ] [
        dynamic-ifte
    ( ] ifte ) ;

\ ifte [ infer-ifte ] "infer" set-word-property

: vtable>list ( value -- list )
    dup value-recursion swap literal-value vector>list
    [ over <literal> ] map nip ;

: infer-dispatch ( -- )
    #! Infer effects for all branches, unify.
    [ object vector ] ensure-d
    dataflow-drop, pop-d vtable>list
    [ f cons ] map
    >r 1 meta-d get vector-tail* #dispatch r>
    pop-d drop ( n )
    infer-branches ;

USE: kernel-internals
\ dispatch [ infer-dispatch ] "infer" set-word-property
\ dispatch [ [ fixnum vector ] [ ] ]
"infer-effect" set-word-property
