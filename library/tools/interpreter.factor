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

IN: interpreter
USE: vectors
USE: namespaces
USE: logic
USE: kernel
USE: combinators
USE: lists
USE: words
USE: stack
USE: errors
USE: continuations
USE: strings
USE: prettyprint
USE: stdio

! A Factor interpreter written in Factor. Used by compiler for
! partial evaluation, also for trace and step.

! Meta-stacks
SYMBOL: meta-r
: push-r meta-r get vector-push ;
: pop-r meta-r get vector-pop ;
SYMBOL: meta-d
: push-d meta-d get vector-push ;
: pop-d meta-d get vector-pop ;
SYMBOL: meta-n
SYMBOL: meta-c

! Call frame
SYMBOL: meta-cf

: init-interpreter ( -- )
    10 <vector> meta-r set
    10 <vector> meta-d set
    10 <vector> meta-n set
    10 <vector> meta-c set
    f meta-cf set ;

: copy-interpreter ( -- )
    #! Copy interpreter state from containing namespaces.
    meta-r get vector-clone meta-r set
    meta-d get vector-clone meta-d set
    meta-n get vector-clone meta-n set
    meta-c get vector-clone meta-c set ;

: done-cf? ( -- ? )
    meta-cf get not ;

: done? ( -- ? )
    done-cf? meta-r get vector-empty? and ;

! Callframe.
: up ( -- )
    pop-r meta-cf set ;

: next ( -- obj )
    meta-cf get [ meta-cf uncons@ ] [ up next ] ifte ;

: host-word ( word -- )
    #! Swap in the meta-interpreter's stacks, execute the word,
    #! swap in the old stacks. This is so messy.
    push-d datastack push-d
    meta-d get set-datastack
    >r execute datastack r> tuck vector-push
    set-datastack meta-d set ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    meta-cf get [ push-r ] when* meta-cf set ;

: meta-word ( word -- )
    dup "meta-word" word-property dup [
        nip call
    ] [
        drop dup compound? [
            word-parameter meta-call
        ] [
            host-word
        ] ifte
    ] ifte ;

: do ( obj -- )
    dup word? [ meta-word ] [ push-d ] ifte ;

: (interpret) ( quot -- )
    #! The quotation is called with each word as its executed.
    done? [ drop ] [ [ next swap call ] keep (interpret) ] ifte ;

: interpret ( quot quot -- )
    #! The first quotation is meta-interpreted, with each word
    #! passed to the second quotation. Pollutes current
    #! namespace.
    init-interpreter swap meta-cf set (interpret) ;

: (run) ( -- )
    [ do ] (interpret) ;

: run ( quot -- )
    [ do ] interpret ;

: set-meta-word ( word quot -- )
    "meta-word" set-word-property ;

\ datastack [ meta-d get vector-clone push-d ] set-meta-word
\ set-datastack [ pop-d vector-clone meta-d set ] set-meta-word
\ >r   [ pop-d push-r ] set-meta-word
\ r>   [ pop-r push-d ] set-meta-word
\ callstack [ meta-r get vector-clone push-d ] set-meta-word
\ set-callstack [ pop-d vector-clone meta-r set ] set-meta-word
\ namestack* [ meta-n get push-d ] set-meta-word
\ set-namestack* [ pop-d meta-n set ] set-meta-word
\ catchstack* [ meta-c get push-d ] set-meta-word
\ set-catchstack* [ pop-d meta-c set ] set-meta-word
\ call [ pop-d meta-call ] set-meta-word
\ execute [ pop-d meta-word ] set-meta-word
\ ifte [ pop-d pop-d pop-d [ nip ] [ drop ] ifte meta-call ] set-meta-word

! Some useful tools

: report ( obj -- )
    meta-r get vector-length " " fill write . flush ;

: (trace) ( -- )
    [ dup report do ] (interpret) ;

: trace ( quot -- )
    #! Trace execution of a quotation by printing each word as
    #! its executed, and each literal as its pushed. Each line
    #! is indented by the call stack height.
    [
        init-interpreter
        meta-cf set
        (trace)
        meta-d get set-datastack
    ] with-scope ;

: walk-banner ( -- )
    "The following words control the single-stepper:" print
    "&s      -- print stepper data stack" print
    "&r      -- print stepper call stack" print
    "&n      -- print stepper name stack" print
    "&c      -- print stepper catch stack" print
    "step    -- single step" print
    "(trace) -- trace until end" print
    "(run)   -- run until end" print ;

: walk ( quot -- )
    #! Single-step through execution of a quotation.
    init-interpreter
    meta-cf set
    walk-banner ;

: &s
    #! Print stepper data stack.
    meta-d get {.} ;

: &r
    #! Print stepper call stack.
    meta-r get {.} meta-cf get . ;

: &n
    #! Print stepper name stack.
    meta-n get {.} ;

: &c
    #! Print stepper catch stack.
    meta-c get {.} ;

: not-done ( quot -- )
    done? [ "Stepper is done." print drop ] [ call ] ifte ;

: step
    #! Step into current word.
    [ next dup report do ] not-done ;
