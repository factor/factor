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

GENERIC: empty? ( sequence -- ? )
GENERIC: length ( sequence -- n )
GENERIC: set-length ( n sequence -- )
GENERIC: nth ( n sequence -- obj )
GENERIC: set-nth ( value n sequence -- obj )
GENERIC: thaw ( seq -- mutable-seq )
GENERIC: like ( seq seq -- seq )
GENERIC: reverse ( seq -- seq )
GENERIC: reverse-slice ( seq -- seq )
GENERIC: peek ( seq -- elt )
GENERIC: head ( n seq -- seq )
GENERIC: tail ( n seq -- seq )
GENERIC: concat ( seq -- seq )
GENERIC: resize ( n seq -- seq )

: immutable ( seq quot -- seq | quot: seq -- )
    swap [ thaw ] keep >r dup >r swap call r> r> like ; inline

G: each ( seq quot -- | quot: elt -- )
    [ over ] [ type ] ; inline

: each-with ( obj seq quot -- | quot: obj elt -- )
    swap [ with ] each 2drop ; inline

: reduce ( seq identity quot -- value | quot: x y -- z )
    swapd each ; inline

G: find ( seq quot -- i elt | quot: elt -- ? )
    [ over ] [ type ] ; inline

: find-with ( obj seq quot -- i elt | quot: elt -- ? )
    swap [ with rot ] find 2swap 2drop ; inline

G: find* ( i seq quot -- i elt | quot: elt -- ? )
    [ over ] [ type ] ; inline

: find-with* ( obj i seq quot -- i elt | quot: elt -- ? )
    -rot [ with rot ] find* 2swap 2drop ; inline

: first 0 swap nth ; inline
: second 1 swap nth ; inline
: third 2 swap nth ; inline
: fourth 3 swap nth ; inline

: push ( element sequence -- )
    #! Push a value on the end of a sequence.
    dup length swap set-nth ;

: 2nth ( s s n -- x x ) tuck swap nth >r swap nth r> ;

: 2unseq ( { x y } -- x y )
    dup first swap second ;

: 3unseq ( { x y z } -- x y z )
    dup first over second rot third ;
