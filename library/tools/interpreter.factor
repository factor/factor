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
USE: kernel
USE: lists
USE: words
USE: errors
USE: strings
USE: prettyprint
USE: stdio

! A Factor interpreter written in Factor. Used by compiler for
! partial evaluation, also for trace and step.

! Meta-stacks
USE: listener
SYMBOL: meta-r
: push-r meta-r get vector-push ;
: pop-r meta-r get vector-pop ;
SYMBOL: meta-d
: push-d meta-d get vector-push ;
: pop-d meta-d get vector-pop ;
: peek-d meta-d get vector-peek ;
SYMBOL: meta-n
SYMBOL: meta-c

! Call frame
SYMBOL: meta-cf

: init-interpreter ( -- )
    10 <vector> meta-r set
    10 <vector> meta-d set
    namestack meta-n set
    f meta-c set
    f meta-cf set ;

: copy-interpreter ( -- )
    #! Copy interpreter state from containing namespaces.
    meta-r [ vector-clone ] change
    meta-d [ vector-clone ] change
    meta-n [ ] change
    meta-c [ ] change ;

: done-cf? ( -- ? )
    meta-cf get not ;

: done? ( -- ? )
    done-cf? meta-r get vector-length 0 = and ;

! Callframe.
: up ( -- )
    pop-r meta-cf set ;

: next ( -- obj )
    meta-cf get [ meta-cf [ uncons ] change ] [ up next ] ifte ;

: host-word ( word -- )
    #! Swap in the meta-interpreter's stacks, execute the word,
    #! swap in the old stacks. This is so messy.
    push-d datastack push-d
    meta-d get set-datastack
    >r execute datastack r> tuck vector-push
    set-datastack meta-d set ;

: meta-call ( quot -- )
    #! Note we do tail call optimization here.
    meta-cf [ [ push-r ] when* ] change ;

: meta-word ( word -- )
    dup "meta-word" word-property [
        call
    ] [
        dup compound? [
            word-parameter meta-call
        ] [
            host-word
        ] ifte
    ] ?ifte ;

: do ( obj -- )
    dup word? [ meta-word ] [ push-d ] ifte ;

: meta-word-1 ( word -- )
    dup "meta-word" word-property [ call ] [ host-word ] ?ifte ;

: do-1 ( obj -- )
    dup word? [ meta-word-1 ] [ push-d ] ifte ;

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
\ namestack [ meta-n get push-d ] set-meta-word
\ set-namestack [ pop-d meta-n set ] set-meta-word
\ catchstack [ meta-c get push-d ] set-meta-word
\ set-catchstack [ pop-d meta-c set ] set-meta-word
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

: &s
    #! Print stepper data stack.
    meta-d get {.} ;

: &r
    #! Print stepper call stack.
    meta-r get {.} meta-cf get . ;

: &n
    #! Print stepper name stack.
    meta-n get [.] ;

: &c
    #! Print stepper catch stack.
    meta-c get [.] ;

: &get ( var -- value )
    #! Print stepper variable value.
    meta-n get (get) ;

: not-done ( quot -- )
    done? [ "Stepper is done." print drop ] [ call ] ifte ;

: next-report ( -- obj )
    next dup report meta-cf get report ;

: step
    #! Step into current word.
    [ next-report do-1 ] not-done ;

: into
    #! Step into current word.
    [ next-report do ] not-done ;

: walk-banner ( -- )
    "The following words control the single-stepper:" print
    [ &s &r &n &c ] [ prettyprint-1 " " write ] each
    "show stepper stacks." print
    \ &get prettyprint-1
    " ( var -- value ) inspects the stepper namestack." print
    \ step prettyprint-1 " -- single step over" print
    \ into prettyprint-1 " -- single step into" print
    \ (trace) prettyprint-1 " -- trace until end" print
    \ (run) prettyprint-1 " -- run until end" print
    \ exit prettyprint-1 " -- exit single-stepper" print ;

: walk ( quot -- )
    #! Single-step through execution of a quotation.
    [
        "walk" listener-prompt set
        init-interpreter
        meta-cf set
        walk-banner
        listener
    ] with-scope ;
