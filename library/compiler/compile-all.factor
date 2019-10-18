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

IN: compiler
USE: combinators
USE: errors
USE: lists
USE: logic
USE: namespaces
USE: prettyprint
USE: stack
USE: stdio
USE: vectors
USE: words

! A set of words to determine a set of words :-) that can be
! compiled.
!
! The heuristic is rather dumb; it errs on the side of safety
! and assumes that any vector or list will potentually contain
! words that will be compiled; so it will refuse to recognize
! this as being compilable for instance:
!
! : foo { 1 2 3 call } vector-nth ;
!
! Even though the instance of 'call' is never compiled here.

DEFER: can-compile?
DEFER: can-compile-list?
DEFER: can-compile-vector?

: can-compile-reference? ( word -- ? )
    #! We cannot compile a symbol, but we can compile a
    #! reference to a symbol. Similarly, we can compile a
    #! reference to a word with special compilation behavior,
    #! but we cannot compile the word itself.
    [
        [ symbol? ] [ drop t ]
        [ "interpret-only" word-property ] [ drop f ]
        [ "compiling" word-property ] [ drop t ]
        [ can-compile? ] [ drop t ]
        [ drop t ] [ drop f ]
    ] cond ;

: can-compile-object? ( obj -- ? )
    [
        [ word? ] [ can-compile-reference? ]
        [ list? ] [ can-compile-list? ]
        [ vector? ] [ can-compile-vector? ]
        [ drop t ] [ drop t ]
    ] cond ;

: can-compile-vector? ( quot -- ? )
    [ can-compile-object? ] vector-all? ;

: can-compile-list? ( quot -- ? )
    [ can-compile-object? ] all? ;

: (can-compile) ( word -- ? )
    #! We can't actually compile a word itself that has
    #! special compilation behavior.
    [
        [ "interpret-only" word-property ] [ drop f ]
        [ "compiling" word-property ] [ drop f ]
        [ compound? ] [ word-parameter can-compile-list? ]
        [ compiled? ] [ drop t ]
        [ drop t ] [ drop f ]
    ] cond ;

: can-compile? ( word -- ? )
    #! We set it to true, then compute the actual flag, so that
    #! mutually recursive words are processed without an
    #! infinite loop.
    dup "can-compile" word-property [
        drop t
    ] [
        t over "can-compile" set-word-property
        dup >r (can-compile) dup r>
        "can-compile" set-word-property
    ] ifte ;

SYMBOL: compilable-word-list

: compilable-words ( -- list )
    #! Make a list of all words that can be compiled.
    [, [ dup can-compile? [ , ] [ drop ] ifte ] each-word ,] ;

: cannot-compile ( word -- )
    "verbose-compile" get [ "Cannot compile " write . ] when ;

: init-compiler ( -- )
    #! Compile all words.
    compilable-word-list get [
        [ compile ] [ [ cannot-compile ] when ] catch
    ] each ;
