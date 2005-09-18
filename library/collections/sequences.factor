! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: sequences
USING: errors generic kernel math math-internals strings vectors ;

! This file is needed very early in bootstrap.

! Sequences support the following protocol. Concrete examples
! are strings, string buffers, vectors, and arrays. Arrays are
! low level and no | quot: elt -- ? t bounds-checked; they are in the
! kernel-internals vocabulary, so don't use them unless you have
! a good reason.

GENERIC: empty? ( sequence -- ? ) flushable
GENERIC: length ( sequence -- n ) flushable
GENERIC: set-length ( n sequence -- )
GENERIC: nth ( n sequence -- obj ) flushable
GENERIC: set-nth ( value n sequence -- obj )
GENERIC: thaw ( seq -- mutable-seq ) flushable
GENERIC: like ( seq seq -- seq ) flushable
GENERIC: reverse ( seq -- seq ) flushable
GENERIC: reverse-slice ( seq -- seq ) flushable
GENERIC: peek ( seq -- elt ) flushable
GENERIC: head ( n seq -- seq ) flushable
GENERIC: tail ( n seq -- seq ) flushable
GENERIC: resize ( n seq -- seq )

: immutable ( seq quot -- seq | quot: seq -- )
    swap [ thaw ] keep >r dup >r swap call r> r> like ; inline

: first 0 swap nth ; inline
: second 1 swap nth ; inline
: third 2 swap nth ; inline
: fourth 3 swap nth ; inline

: push ( element sequence -- )
    #! Push a value on the end of a sequence.
    dup length swap set-nth ; inline

: first2 ( { x y } -- x y )
    dup first swap second ; inline

: first3 ( { x y z } -- x y z )
    dup first over second rot third ; inline

TUPLE: bounds-error index seq ;

: bounds-error <bounds-error> throw ;

: growable-check ( n seq -- fx seq )
    >r >fixnum dup 0 fixnum<
    [ r> 2dup bounds-error ] [ r> ] ifte ; inline

: bounds-check ( n seq -- fx seq )
    growable-check 2dup length fixnum>=
    [ 2dup bounds-error ] when ; inline

IN: sequences-internals

! Unsafe sequence protocol for inner loops
GENERIC: nth-unsafe
GENERIC: set-nth-unsafe

M: object nth-unsafe nth ;
M: object set-nth-unsafe set-nth ;

: 2nth-unsafe ( s s n -- x x )
    tuck swap nth-unsafe >r swap nth-unsafe r> ; inline

: change-nth-unsafe ( seq i quot -- )
    pick pick >r >r >r swap nth-unsafe
    r> call r> r> swap set-nth-unsafe ; inline
