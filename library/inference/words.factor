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

: apply-effect ( word [ in | out ] -- )
    #! If a word does not have special inference behavior, we
    #! either execute the word in the meta interpreter (if it is
    #! side-effect-free and all parameters are literal), or
    #! simply apply its stack effect to the meta-interpreter.
    dup car pick dataflow-word,
    swap "infer" word-property dup [
        swap car ensure-d call
    ] [
        drop consume/produce
    ] ifte ;

: no-effect ( word -- )
    "Unknown stack effect: " swap word-name cat2 throw ;

: infer-compound ( word -- effect )
    #! Infer a word's stack effect, and cache it.
    [
        recursive-state get init-inference
        [
            dup word-parameter (infer) effect
            [ "infer-effect" set-word-property ] keep
        ] with-recursive-state
    ] with-scope ;

: inline-compound ( word -- )
    [ word-parameter (infer) ] with-recursive-state ;

: apply-compound ( word -- )
    #! Infer a compound word's stack effect.
    dup "inline" word-property [
        inline-compound
    ] [
        dup infer-compound dup car rot dataflow-word,
        consume/produce
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
                [ compound? ] [ apply-compound ]
                [ symbol?   ] [ apply-literal  ]
                [ drop t    ] [ no-effect      ]
            ] cond
        ] ifte
    ] ifte ;

: infer-call ( [ rstate | quot ] -- )
    1 \ drop dataflow-word,
    [
        dataflow-graph off
        pop-d uncons recursive-state set (infer)
        d-in get meta-d get get-dataflow
    ] with-scope
    [ dataflow-graph cons@ ] each meta-d set d-in set ;

\ call [ infer-call ] "infer" set-word-property

\ + [ 2 | 1 ] "infer-effect" set-word-property
\ - [ 2 | 1 ] "infer-effect" set-word-property
\ * [ 2 | 1 ] "infer-effect" set-word-property
\ / [ 2 | 1 ] "infer-effect" set-word-property
