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
USE: hashtables
USE: kernel
USE: lists
USE: logic
USE: math
USE: namespaces
USE: parser
USE: prettyprint
USE: stack
USE: stdio
USE: strings
USE: unparser
USE: vectors
USE: words

! We use a hashtable "compiled-xts" that maps words to
! xt's that are currently being compiled. The commit-xt's word
! sets the xt of each word in the hashtable to the value in the
! hastable.
!
! This has the advantage that we can compile a word before the
! words it depends on and perform a fixup later; among other
! things this enables mutually recursive words.

SYMBOL: compiled-xts

: save-xt ( word -- )
    cell compile-aligned
    compiled-offset swap compiled-xts acons@ ;

: commit-xt ( xt word -- )
    t over "compiled" set-word-property  set-word-xt ;

: commit-xts ( -- )
    compiled-xts get [ unswons commit-xt ] each
    compiled-xts off ;

: compiled-xt ( word -- xt )
    dup compiled-xts get assoc [ nip ] [ word-xt ] ifte* ;

! "deferred-xts" is a list of [ where word relative ] pairs; the
! xt of word when its done compiling will be written to the
! offset, relative to the offset.

SYMBOL: deferred-xts

! Words being compiled are consed onto this list. When a word
! is encountered that has not been previously compiled, it is
! consed onto this list. Compilation stops when the list is
! empty.

SYMBOL: compile-words

: defer-xt ( word where relative -- )
    #! After word is compiled, put its XT at where, relative.
    3list deferred-xts cons@ ;

: compiling? ( word -- ? )
    #! A word that is compiling or already compiled will not be
    #! added to the list of words to be compiled.
    dup compiled? [
        drop t
    ] [
        dup compile-words get contains? [
            drop t
        ] [
            compiled-xts get assoc
        ] ifte
    ] ifte ;

: fixup-deferred-xt ( word where relative -- )
    rot dup compiling? [
        compiled-xt swap - swap set-compiled-cell
    ] [
        "Not compiled: " swap word-name cat2 throw
    ] ifte ;

: fixup-deferred-xts ( -- )
    deferred-xts get [
        uncons uncons car fixup-deferred-xt
    ] each
    deferred-xts off ;

: postpone-word ( word -- )
    dup compiling? [ drop ] [ compile-words unique@ ] ifte ;

! During compilation, these two variables store pending
! literals. Literals are either consumed at compile-time by
! words with special compilation behavior, or otherwise they are
! compiled into code that pushes them.

SYMBOL: compile-datastack
SYMBOL: compile-callstack

: pop-literal ( -- obj )
    compile-datastack get vector-pop ;

: immediate? ( obj -- ? )
    #! fixnums and f have a pointerless representation, and
    #! are compiled immediately. Everything else can be moved
    #! by GC, and is indexed through a table.
    dup fixnum? swap f eq? or ;

: compile-literal ( obj -- )
    dup immediate? [
        address LITERAL
    ] [
        intern-literal [LITERAL]
    ] ifte ;

: commit-literals ( -- )
    compile-datastack get
    dup vector-empty? [
        drop
    ] [
        dup [ compile-literal ] vector-each
        0 swap set-vector-length
    ] ifte ;

: postpone-literal ( obj -- )
    #! Literals are not compiled immediately, so that words like
    #! ifte with special compilation behavior can work.
    compile-datastack get vector-push ;

: tail? ( -- ? )
    compile-callstack get vector-empty? ;

: compile-simple-word ( word -- )
    #! Compile a JMP at the end (tail call optimization)
    dup postpone-word
    commit-literals tail? [ JUMP ] [ CALL ] ifte
    compiled-offset defer-xt ;

: compile-word ( word -- )
    #! If a word has a compiling property, then it has special
    #! compilation behavior.
    dup "compiling" word-property dup [
        nip call
    ] [
        drop compile-simple-word
    ] ifte ;

: begin-compiling-quot ( quot -- )
    compile-callstack get vector-push ;

: end-compiling-quot ( -- )
    compile-callstack get vector-pop drop ;

: compiling ( quot -- )
    #! Called on each iteration of compile-loop, with the
    #! remaining quotation.
    [
        compile-callstack get
        dup vector-length pred
        swap set-vector-nth
    ] [
        end-compiling-quot
    ] ifte* ;

: compile-atom ( obj -- )
    dup word? [ compile-word ] [ postpone-literal ] ifte ;

: compile-loop ( quot -- )
    [
        uncons  dup compiling  swap compile-atom  compile-loop
    ] when* ;

: compile-quot ( quot -- )
    [
        dup begin-compiling-quot compile-loop commit-literals
    ] when* ;

: with-compiler ( quot -- )
    [
        10 <vector> compile-datastack set
        10 <vector> compile-callstack set
        call
        fixup-deferred-xts
        commit-xts
    ] with-scope ;

: (compile) ( word -- )
    #! Should be called inside the with-compiler scope.
    dup . flush
    intern dup save-xt word-parameter compile-quot RET ;

: compile-postponed ( -- )
    compile-words get [
        uncons compile-words set (compile) compile-postponed
    ] when* ;

: compile ( word -- )
    [ postpone-word compile-postponed ] with-compiler ;

: compiled word compile ; parsing
