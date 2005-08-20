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
GENERIC: set-length ( n sequence -- ) flushable
GENERIC: nth ( n sequence -- obj ) flushable
GENERIC: set-nth ( value n sequence -- obj ) flushable
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

G: each ( seq quot -- | quot: elt -- )
    [ over ] [ standard-combination ] ; inline

: each-with ( obj seq quot -- | quot: obj elt -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- value | quot: x y -- z )
    swapd each ; inline

G: find ( seq quot -- i elt | quot: elt -- ? )
    [ over ] [ standard-combination ] ; inline

: find-with ( obj seq quot -- i elt | quot: elt -- ? )
    swap [ with rot ] find 2swap 2drop ; inline

: first 0 swap nth ; inline
: second 1 swap nth ; inline
: third 2 swap nth ; inline
: fourth 3 swap nth ; inline

: push ( element sequence -- )
    #! Push a value on the end of a sequence.
    dup length swap set-nth ; inline

: 2nth ( s s n -- x x ) tuck swap nth >r swap nth r> ; inline

: 2unseq ( { x y } -- x y )
    dup first swap second ; inline

: 3unseq ( { x y z } -- x y z )
    dup first over second rot third ; inline

TUPLE: bounds-error index seq ;
: bounds-error <bounds-error> throw ;

: growable-check ( n seq -- fx seq )
    >r >fixnum dup 0 fixnum<
    [ r> 2dup bounds-error ] [ r> ] ifte ; inline

: bounds-check ( n seq -- fx seq )
    growable-check 2dup length fixnum>=
    [ 2dup bounds-error ] when ; inline
