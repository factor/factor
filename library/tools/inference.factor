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
! - meta-infer -- evaluate word in meta-interpreter if set.
! - infer - quotation with custom inference behavior; ifte uses
! this. Word is passed on the stack.

! Amount of results we had to add to the datastack
SYMBOL: d-in
! Amount of results we had to add to the callstack
SYMBOL: r-in
! Recursive state. Alist maps words to base case effects
SYMBOL: recursive-state

: gensym-vector ( n --  vector )
    dup <vector> swap [ gensym over vector-push ] times ;

: inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    >r gensym-vector dup r> vector-append ;

: ensure ( count stack -- count stack )
    #! Ensure stack has this many elements.
    2dup vector-length > [
        [ vector-length - dup ] keep inputs
    ] [
        >r drop 0 r>
    ] ifte ;

: ensure-d ( count -- )
    #! Ensure count of unknown results are on the stack.
    meta-d get ensure meta-d set d-in +@ ;

: consume-d ( count -- )
    #! Remove count of elements.
    [ pop-d drop ] times ;

: produce-d ( count -- )
    #! Push count of unknown results.
    [ gensym push-d ] times ;

: consume/produce ( [ in | out ] -- )
    unswons dup ensure-d consume-d produce-d ;

: standard-effect ( word [ in | out ] -- )
    #! If a word does not have special inference behavior, we
    #! either execute the word in the meta interpreter (if it is
    #! side-effect-free and all parameters are literal), or
    #! simply apply its stack effect to the meta-interpreter.
    over "meta-infer" word-property [
        drop host-word
    ] [
        nip consume/produce
    ] ifte ;

: apply-effect ( word [ in | out ] -- )
    #! Helper word for apply-word.
    dup car ensure-d
    over "infer" word-property dup [
        nip nip call
    ] [
        drop standard-effect
    ] ifte ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name cat2 throw ;

DEFER: (infer)

: apply-compound ( word -- )
    t over recursive-state acons@
    word-parameter (infer)
    recursive-state uncons@ drop ;

: apply-word ( word -- )
    #! Apply the word's stack effect to the inferencer state.
    dup "infer-effect" word-property dup [
        apply-effect
    ] [
        drop dup compound? [ apply-compound ] [ no-effect ] ifte
    ] ifte ;

: current-word ( -- word )
    #! Push word we're currently inferring effect of.
    recursive-state get car car ;

: no-base-case ( -- )
    current-word word-name
    " does not have a base case." cat2 throw ;

: check-recursion ( -- )
    #! If at the location of the recursive call, we're taking
    #! more items from the stack than producing, we have a
    #! diverging recursion.
    d-in get meta-d get vector-length > [
        current-word word-name " diverges." cat2 throw
    ] when ;

: recursive-word ( word effect -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error.
    dup t = [ drop no-base-case ] [ nip consume/produce ] ifte ;

: apply-object ( obj -- )
    #! Apply the object's stack effect to the inferencer state.
    dup word? [
        dup recursive-state get assoc [
            check-recursion recursive-word
        ] [
            apply-word
        ] ifte*
    ] [
        push-d
    ] ifte ;

: init-inference ( -- )
    init-interpreter
    0 d-in set
    0 r-in set
    f recursive-state set ;

: effect ( -- [ in | out ] )
    #! After inference is finished, collect information.
    d-in get meta-d get vector-length cons ;

: (infer) ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ apply-object ] each ;

: (infer-branch) ( quot -- [ in-d | datastack ] )
    #! Infer the quotation's effect, restoring the meta
    #! interpreter state afterwards.
    [
        copy-interpreter (infer)
        d-in get  meta-d get cons
    ] with-scope ;

: infer-branch ( quot -- [ in-d | datastack ] )
    #! Push f if inference failed.
    [ (infer-branch) ] [ [ drop f ] when ] catch ;

: difference ( [ in | stack ] -- diff )
    #! Stack height difference of infer-branch return value.
    uncons vector-length - ;

: balanced? ( [ in | stack ] [ in | stack ] -- ? )
    #! Check if two stack effects preserve stack height.
    difference swap difference = ;

: max-vector-length ( vector vector -- length )
    swap vector-length swap vector-length max ;

: unify-lengths ( stack stack -- stack stack )
    #! If one vector is shorter, pad it with unknown results at
    #! the bottom.
    2dup max-vector-length
    tuck swap ensure nip >r swap ensure nip r> ;

: unify-result ( obj obj -- obj )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ 2drop gensym ] ifte ;

: unify-stacks ( stack stack -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    unify-lengths [ unify-result ] vector-2map ;

: unify ( [ in | stack ] [ in | stack ] -- )
    #! Unify meta-interpreter state from two branches.
    2dup balanced? [
        2dup
        2car max d-in set
        2cdr unify-stacks meta-d set
    ] [
        "Unbalanced ifte branches" throw
    ] ifte ;

: set-base ( [ in | stack ] -- )
    #! Set the base case of the current word.
    recursive-state uncons@ car >r
    uncons vector-length cons r>
    recursive-state acons@ ;

: recursive-branches ( false true fe te -- fe te )
    #! At least one of the branches did not have a computable
    #! stack effect. Set the base case to the other branch, and
    #! try again.
    2dup or [
        dup [
            dup set-base >r 2drop infer-branch r>
        ] [
            drop dup set-base swap infer-branch rot drop
        ] ifte
    ] [
        no-base-case
    ] ifte ;

: infer-branches ( false true -- [ in | stack ] [ in | stack ] )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    over infer-branch over infer-branch 2dup and [
        2nip ( all good )
    ] [
        recursive-branches
    ] ifte ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    pop-d pop-d pop-d drop ( condition ) infer-branches unify ;

: infer ( quot -- [ in | out ] )
    #! Stack effect of a quotation.
    [ init-inference (infer)  effect ] with-scope ;

\ call [ pop-d (infer) ] "infer" set-word-property
\ ifte [ infer-ifte ] "infer" set-word-property

\ >r [ pop-d push-r ] "infer" set-word-property
\ r> [ pop-r push-d ] "infer" set-word-property

\ drop  t "meta-infer" set-word-property
\ dup  t "meta-infer" set-word-property
\ swap t "meta-infer" set-word-property
\ over t "meta-infer" set-word-property
\ pick t "meta-infer" set-word-property
\ nip t "meta-infer" set-word-property
\ tuck t "meta-infer" set-word-property
\ rot t "meta-infer" set-word-property
