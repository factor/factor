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
! - recursive-infer - if true, inferencer will always invoke
! itself recursively with this word, instead of solving a
! fixed-point equation for recursive calls.

! Amount of results we had to add to the datastack
SYMBOL: d-in
! Amount of results we had to add to the callstack
SYMBOL: r-in

! Recursive state. Alist maps words to hashmaps...
SYMBOL: recursive-state
! ... with keys:
SYMBOL: base-case
SYMBOL: entry-effect

: gensym-vector ( n --  vector )
    dup <vector> swap [ gensym over vector-push ] times ;

: inputs ( count stack -- stack )
    #! Add this many inputs to the given stack.
    >r gensym-vector dup r> vector-append ;

: ensure ( count stack -- count stack )
    #! Ensure stack has this many elements. Return number of
    #! elements added.
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

: (effect) ( -- [ in | stack ] )
    d-in get  meta-d get cons ;

: effect ( -- [ in | out ] )
    #! After inference is finished, collect information.
    d-in get  meta-d get vector-length cons ;

: <recursive-state> ( -- state )
    <namespace> [
        base-case off  effect entry-effect set
    ] extend ;

DEFER: (infer)

: apply-compound ( word -- )
    #! Infer a compound word's stack effect.
    dup <recursive-state> cons recursive-state cons@
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

: current-state ( -- word )
    #! Push word we're currently inferring effect of.
    recursive-state get car cdr ;

: no-base-case ( word -- )
    word-name " does not have a base case." cat2 throw ;

: check-recursion ( -- )
    #! If at the location of the recursive call, we're taking
    #! more items from the stack than producing, we have a
    #! diverging recursion.
    d-in get meta-d get vector-length > [
        current-word word-name " diverges." cat2 throw
    ] when ;

: recursive-word ( word state -- )
    #! Handle a recursive call, by either applying a previously
    #! inferred base case, or raising an error.
    base-case swap hash dup [
        nip consume/produce
    ] [
        drop no-base-case
    ] ifte ;

: apply-object ( obj -- )
    #! Apply the object's stack effect to the inferencer state.
    #! There are three options: recursive-infer words always
    #! cause a recursive call of the inferencer, regardless.
    #! Be careful, you might hang the inferencer. Other words
    #! solve a fixed-point equation if a recursive call is made,
    #! otherwise the inferencer is invoked recursively if its
    #! not a recursive call.
    dup word? [
        dup "recursive-infer" word-property [
            apply-word
        ] [
            dup recursive-state get assoc dup [
                check-recursion recursive-word
            ] [
                drop apply-word
            ] ifte
        ] ifte
    ] [
        push-d
    ] ifte ;

: init-inference ( -- )
    init-interpreter
    0 d-in set
    0 r-in set
    f recursive-state set ;

: (infer) ( quot -- )
    #! Recursive calls to this word are made for nested
    #! quotations.
    [ apply-object ] each ;

: infer-branch ( quot -- [ in-d | datastack ] )
    #! Infer the quotation's effect, restoring the meta
    #! interpreter state afterwards.
    [ copy-interpreter (infer) (effect) ] with-scope ;

: difference ( [ in | stack ] -- diff )
    #! Stack height difference of infer-branch return value.
    uncons vector-length - ;

: balanced? ( list -- ? )
    #! Check if a list of [ in | stack ] pairs has the same
    #! stack height.
    [ difference ] map all=? ;

: max-vector-length ( list -- length )
    [ vector-length ] map [ > ] top ;

: unify-lengths ( list -- list )
    #! Pad all vectors to the same length. If one vector is
    #! shorter, pad it with unknown results at the bottom.
    dup max-vector-length swap [ dupd ensure nip ] map nip ;

: unify-result ( obj obj -- obj )
    #! Replace values with unknown result if they differ,
    #! otherwise retain them.
    2dup = [ drop ] [ 2drop gensym ] ifte ;

: unify-stacks ( list -- stack )
    #! Replace differing literals in stacks with unknown
    #! results.
    uncons [ [ unify-result ] vector-2map ] each ;

: unify ( list -- )
    #! Unify meta-interpreter state from two branches.
    dup balanced? [
        unzip
        unify-lengths unify-stacks meta-d set
        [ > ] top d-in set
    ] [
        "Unbalanced branches" throw
    ] ifte ;

: compose ( first second -- total )
    #! Stack effect composition.
    >r uncons r> uncons >r -
    dup 0 < [ neg + r> cons ] [ r> + cons ] ifte ;

: decompose ( first second -- solution )
    #! Return a stack effect such that first*solution = second.
    2dup 2car
    2dup > [ "No solution to decomposition" throw ] when
    swap - -rot 2cdr >r + r> cons ;

: set-base ( [ in | stack ] -- )
    #! Set the base case of the current word.
    uncons vector-length cons
    current-state [
        entry-effect get swap decompose base-case set
    ] bind ;

: recursive-branch ( quot -- )
    #! Set base case if inference didn't fail
    [ infer-branch set-base ] [ [ drop ] when ] catch ;

: infer-branches ( brachlist -- )
    #! Recursive stack effect inference is done here. If one of
    #! the branches has an undecidable stack effect, we set the
    #! base case to this stack effect and try again.
    dup [ recursive-branch ] each [ infer-branch ] map unify ;

: infer-ifte ( -- )
    #! Infer effects for both branches, unify.
    pop-d pop-d 2list pop-d drop ( condition ) infer-branches ;

: vtable>list ( vtable -- list )
    #! generic and 2generic use vectors of words, we need lists
    #! of quotations. Filter out no-method. Dirty workaround;
    #! later properly handle throw.
    vector>list [
        dup \ no-method = [ drop f ] [ unit ] ifte
    ] map [ ] subset ;

: infer-generic ( -- )
    #! Infer effects for all branches, unify.
    pop-d vtable>list peek-d drop ( dispatch ) infer-branches ;

: infer-2generic ( -- )
    #! Infer effects for all branches, unify.
    pop-d vtable>list
    peek-d drop ( dispatch )
    peek-d drop ( dispatch )
    infer-branches ;

: infer ( quot -- [ in | out ] )
    #! Stack effect of a quotation.
    [ init-inference (infer)  effect ] with-scope ;

\ call [ pop-d (infer) ] "infer" set-word-property
\ ifte [ infer-ifte ] "infer" set-word-property

\ generic [ infer-generic ] "infer" set-word-property
\ generic [ 2 | 0 ] "infer-effect" set-word-property

\ 2generic [ infer-2generic ] "infer" set-word-property
\ 2generic [ 3 | 0 ] "infer-effect" set-word-property

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
