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

: unify-d-in ( list -- d-in )
    0 swap [ [ d-in get ] bind [ max ] when* ] each ;

: balanced? ( list -- ? )
    [ [ d-in get meta-d get and ] bind ] subset
    [ [ d-in get meta-d get vector-length - ] bind ] map all=? ;

: longest-vector ( list -- length )
    [ vector-length ] map [ > ] top ;

: unify-result ( obj obj -- obj )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ 2drop gensym ] ifte ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    uncons [ [ unify-result ] vector-2map ] each ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup longest-vector swap [ dupd ensure nip ] map nip ;

: unify-datastacks ( list -- datastack )
    [ [ meta-d get ] bind ] map [ ] subset
    unify-lengths unify-stacks ;

: check-lengths ( list -- )
    [ vector-length ] map all=? [
        "Unbalanced return stack effect" throw
    ] unless ;

: unify-callstacks ( list -- datastack )
    [ [ meta-r get ] bind ] map [ ] subset
    dup check-lengths unify-stacks ;

: unify ( list -- )
    dup balanced? [
        dup unify-d-in d-in set
        dup unify-datastacks meta-d set
        unify-callstacks meta-r set
    ] [
        "Unbalanced branches" throw
    ] ifte ;

: infer-branch ( rstate quot save-effect -- namespace )
    <namespace> [
        save-effect set
        swap recursive-state set
        copy-interpreter
        dataflow-graph off
        infer-quot
        #values values-node
    ] extend ;

: terminator? ( quot -- ? )
    #! This is a hack. undefined-method has a stack effect that
    #! probably does not match any other branch of the generic,
    #! so we handle it specially.
    \ undefined-method swap tree-contains? ;

: recursive-branch ( rstate quot -- )
    #! Set base case if inference didn't fail.
    [
        f infer-branch [
            d-in get meta-d get vector-length cons
            recursive-state get set-base
        ] bind
    ] [
        [ 2drop ] when
    ] catch ;

: infer-base-case ( branchlist -- )
    [
        unswons dup terminator? [
            2drop
        ] [
            recursive-branch
        ] ifte
    ] each ;

: (infer-branches) ( branchlist -- list )
    dup infer-base-case [
        unswons dup terminator? [
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
    3 ensure-d
    dataflow-drop, pop-d
    dataflow-drop, pop-d swap 2list
    >r 1 meta-d get vector-tail* #ifte r>
    pop-d drop ( condition )
    infer-branches ;

\ ifte [ infer-ifte ] "infer" set-word-property

: vtable>list ( [ vtable | rstate ] -- list )
    unswons vector>list [ over cons ] map nip ;

: infer-dispatch ( -- )
    #! Infer effects for all branches, unify.
    2 ensure-d
    dataflow-drop, pop-d vtable>list
    >r 1 meta-d get vector-tail* #dispatch r>
    pop-d drop ( n )
    infer-branches ;

\ dispatch [ infer-dispatch ] "infer" set-word-property
\ dispatch [ 2 | 0 ] "infer-effect" set-word-property
