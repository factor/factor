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

: longest-vector ( list -- length )
    [ vector-length ] map [ > ] top ;

: computed-value-vector ( n -- vector )
    [ drop object <computed> ] vector-project ;

: add-inputs ( count stack -- count stack )
    #! Add this many inputs to the given stack.
    [ vector-length - dup ] keep
    >r computed-value-vector dup r> vector-append ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup longest-vector swap [ dupd add-inputs nip ] map nip ;

: unify-classes ( value value -- value )
    value-class swap value-class class-or <computed> ;

: unify-results ( value value -- value )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ unify-classes ] ifte ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    uncons [ [ unify-results ] vector-2map ] each ;

: unify-d-in ( list -- d-in )
    [ [ d-in get ] bind ] map unify-lengths unify-stacks ;

: filter-terminators ( list -- list )
    [ [ d-in get meta-d get and ] bind ] subset ;

: balanced? ( list -- ? )
    [
        [
            d-in get vector-length
            meta-d get vector-length -
        ] bind
    ] map all=? ;

: unify-datastacks ( list -- datastack )
    [ [ meta-d get ] bind ] map
    unify-lengths unify-stacks ;

: check-lengths ( list -- )
    [ vector-length ] map all=? [
        "Unbalanced return stack effect" throw
    ] unless ;

: unify-callstacks ( list -- datastack )
    [ [ meta-r get ] bind ] map
    dup check-lengths unify-stacks ;

: unify ( list -- )
    filter-terminators dup balanced? [
        dup unify-d-in d-in set
        dup unify-datastacks meta-d set
        unify-callstacks meta-r set
    ] [
        "Unbalanced branches" throw
    ] ifte ;

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

: terminator? ( quot -- ? )
    #! This is a hack. undefined-method has a stack effect that
    #! probably does not match any other branch of the generic,
    #! so we handle it specially.
    literal-value \ undefined-method swap tree-contains? ;

: recursive-branch ( value -- )
    #! Set base case if inference didn't fail.
    [
        f infer-branch [
            effect old-effect recursive-state get set-base
        ] bind
    ] [
        [ drop ] when
    ] catch ;

: infer-base-case ( branchlist -- )
    [
        dup terminator? [
            drop
        ] [
            recursive-branch
        ] ifte
    ] each ;

: (infer-branches) ( branchlist -- list )
    dup infer-base-case [
        dup terminator? [
            t infer-branch [
                meta-d off meta-r off d-in off
            ] extend
        ] [
            t infer-branch
        ] ifte
    ] map ;

: infer-branches ( inputs instruction branchlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again. The inputs
    #! parameter is a vector.
    (infer-branches) [
        [ [ get-dataflow ] bind ] map
        swap dataflow, [ node-consume-d set ] bind
    ] keep unify ;

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

\ dispatch [ infer-dispatch ] "infer" set-word-property
\ dispatch [ 2 | 0 ] "infer-effect" set-word-property
