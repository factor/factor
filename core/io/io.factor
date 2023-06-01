! Copyright (C) 2003, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: destructors kernel kernel.private math namespaces
sequences sequences.private ;
IN: io

SYMBOLS: +byte+ +character+ ;

GENERIC: stream-element-type ( stream -- type )

GENERIC: stream-read1 ( stream -- elt )
GENERIC: stream-read-unsafe ( n buf stream -- count )
GENERIC: stream-read-until ( seps stream -- seq sep/f )
GENERIC: stream-read-partial-unsafe ( n buf stream -- count )
GENERIC: stream-readln ( stream -- str/f )
GENERIC: stream-contents* ( stream -- seq )
: stream-contents ( stream -- seq ) [ stream-contents* ] with-disposal ;

GENERIC: stream-write1 ( elt stream -- )
GENERIC: stream-write ( data stream -- )
GENERIC: stream-flush ( stream -- )
GENERIC: stream-nl ( stream -- )

ERROR: bad-seek-type type ;

SINGLETONS: seek-absolute seek-relative seek-end ;

GENERIC: stream-tell ( stream -- n )
GENERIC: stream-seek ( n seek-type stream -- )
GENERIC: stream-seekable? ( stream -- ? )
GENERIC: stream-length ( stream -- n/f )

: stream-print ( str stream -- )
    [ stream-write ] [ stream-nl ] bi ; inline

! Default streams
MIXIN: input-stream
MIXIN: output-stream
SYMBOL: error-stream

: readln ( -- str/f ) input-stream get stream-readln ; inline
: read1 ( -- elt ) input-stream get stream-read1 ; inline
: read-until ( seps -- seq sep/f ) input-stream get stream-read-until ; inline
: tell-input ( -- n ) input-stream get stream-tell ; inline
: tell-output ( -- n ) output-stream get stream-tell ; inline
: seek-input ( n seek-type -- ) input-stream get stream-seek ; inline
: seek-output ( n seek-type -- ) output-stream get stream-seek ; inline

: write1 ( elt -- ) output-stream get stream-write1 ; inline
: write ( seq -- ) output-stream get stream-write ; inline
: flush ( -- ) output-stream get stream-flush ; inline

: nl ( -- ) output-stream get stream-nl ; inline

: with-input-stream* ( stream quot -- )
    input-stream swap with-variable ; inline

: with-input-stream ( stream quot -- )
    '[ _ with-input-stream* ] with-disposal ; inline

: with-output-stream* ( stream quot -- )
    output-stream swap with-variable ; inline

: with-output-stream ( stream quot -- )
    '[ _ with-output-stream* ] with-disposal ; inline

: with-error-stream* ( stream quot -- )
    error-stream swap with-variable ; inline

: with-error-stream ( stream quot -- )
    '[ _ with-error-stream* ] with-disposal ; inline

: with-output+error-stream* ( stream quot -- )
    dupd '[ _ with-error-stream* ] with-output-stream* ; inline

: with-output+error-stream ( stream quot -- )
    '[ _ with-output+error-stream* ] with-disposal ; inline

: with-output>error ( quot -- )
    error-stream get swap with-output-stream* ; inline

: with-error>output ( quot -- )
    output-stream get swap with-error-stream* ; inline

: with-streams* ( input output quot -- )
    swapd '[ _ with-output-stream* ] with-input-stream* ; inline

: with-streams ( input output quot -- )
    ! We have to dispose of the output stream first, so that
    ! if both streams point to the same FD, we get to flush the
    ! buffer before closing the FD.
    swapd '[ _ with-output-stream ] with-input-stream ; inline

: with-input-output+error-streams* ( input output+error quot -- )
    swapd '[ _ with-output+error-stream* ] with-input-stream* ; inline

: with-input-output+error-streams ( input output+error quot -- )
    swapd '[ _ with-output+error-stream ] with-input-stream ; inline

: print ( str -- ) output-stream get stream-print ; inline

: stream-bl ( stream -- ) CHAR: \s swap stream-write1 ; inline

: bl ( -- ) output-stream get stream-bl ;

<PRIVATE

: stream-exemplar ( stream -- exemplar )
    stream-element-type +byte+ = B{ } "" ? ; inline

: stream-exemplar-growable ( stream -- exemplar )
    stream-element-type +byte+ = BV{ } SBUF" " ? ; inline

: (new-sequence-for-stream) ( n stream -- seq )
    stream-exemplar new-sequence ; inline

: resize-if-necessary ( wanted-n got-n seq -- seq' )
    2over = [ 2nip ] [ resize nip ] if ; inline

: (read-into-new) ( n stream quot -- seq/f )
    [ dup ] 2dip
    [ 2dup (new-sequence-for-stream) swap ] dip keepd
    over 0 = [ 3drop f ] [ resize-if-necessary ] if ; inline

: (read-into) ( buf stream quot -- buf-slice/f )
    [ dup length over ] 2dip call
    [ head-to-index <slice-unsafe> ] [ zero? not ] bi ; inline

PRIVATE>

: stream-read ( n stream -- seq/f )
    [ stream-read-unsafe ] (read-into-new) ; inline

: stream-read-partial ( n stream -- seq/f )
    [ stream-read-partial-unsafe ] (read-into-new) ; inline

ERROR: invalid-read-buffer buf stream ;

: stream-read-into ( buf stream -- buf-slice more? )
    [ stream-read-unsafe { fixnum } declare ] (read-into) ; inline

: stream-read-partial-into ( buf stream -- buf-slice more? )
    [ stream-read-partial-unsafe { fixnum } declare ] (read-into) ; inline

: read ( n -- seq ) input-stream get stream-read ; inline

: read-partial ( n -- seq ) input-stream get stream-read-partial ; inline

: read-into ( buf -- buf-slice more? )
    input-stream get stream-read-into ; inline

: read-partial-into ( buf -- buf-slice more? )
    input-stream get stream-read-partial-into ; inline

: each-stream-line ( ... stream quot: ( ... line -- ... ) -- ... )
    [ '[ _ stream-readln ] ] dip while* ; inline

: each-line ( ... quot: ( ... line -- ... ) -- ... )
    input-stream get swap each-stream-line ; inline

: stream-lines ( stream -- seq )
    [
        [ ] collector [ each-stream-line ] dip { } like
    ] with-disposal ; inline

: read-lines ( -- seq )
    input-stream get stream-lines ; inline

CONSTANT: each-block-size 65536

: (each-stream-block-slice) ( ... stream quot: ( ... block-slice -- ... ) block-size -- ... )
    -rot [
        [ (new-sequence-for-stream) ] keep
        [ stream-read-partial-into ] 2curry
    ] dip while drop ; inline

: each-stream-block-slice ( ... stream quot: ( ... block-slice -- ... ) -- ... )
    each-block-size (each-stream-block-slice) ; inline

: (each-stream-block) ( ... stream quot: ( ... block -- ... ) block-size -- ... )
    -rot [ [ stream-read-partial ] 2curry ] dip while* ; inline

: each-stream-block ( ... stream quot: ( ... block -- ... ) -- ... )
    each-block-size (each-stream-block) ; inline

: each-block-slice ( ... quot: ( ... block -- ... ) -- ... )
    input-stream get swap each-stream-block-slice ; inline

: each-block ( ... quot: ( ... block -- ... ) -- ... )
    input-stream get swap each-stream-block ; inline

: (stream-contents-by-length) ( stream len -- seq )
    dup rot
    [ (new-sequence-for-stream) ]
    [ [ stream-read-unsafe ] keepd resize ] bi ; inline

: (stream-contents-by-block) ( stream -- seq )
    [ [ ] collector [ each-stream-block ] dip { } like ]
    [ stream-exemplar concat-as ] bi ; inline

: (stream-contents-by-length-or-block) ( stream -- seq )
    dup stream-length
    [ (stream-contents-by-length) ]
    [ (stream-contents-by-block)  ] if* ; inline

: (stream-contents-by-element) ( stream -- seq )
    [
        [ [ stream-read1 dup ] curry [ ] ]
        [ stream-exemplar produce-as nip ] bi
    ] with-disposal ; inline

: read-contents ( -- seq )
    input-stream get stream-contents ; inline

: stream-copy* ( in out -- )
    '[ _ stream-write ] each-stream-block ; inline

: stream-copy ( in out -- )
    '[ _ [ stream-copy* ] with-disposal ] with-disposal ; inline

! Default implementations of stream operations in terms of read1/write1

<PRIVATE

: read-loop ( buf stream n i -- count )
    2dup = [ 3nip ] [
        pick stream-read1 [
            over [ pick set-nth-unsafe ] 2curry 3dip
            1 + read-loop
        ] [ 3nip ] if*
    ] if ; inline recursive

: finalize-read-until ( seq sep/f -- seq/f sep/f )
    [ [ f ] when-empty f ] unless* ; inline

: read-until-loop ( seps stream -- seq sep/f )
    [ [ stream-read1 dup [ rot member? not ] [ nip f ] if* ] 2curry [ ] ]
    [ stream-exemplar ] bi produce-as swap finalize-read-until ; inline

PRIVATE>

M: input-stream stream-read-unsafe rot 0 read-loop ; inline
M: input-stream stream-read-partial-unsafe stream-read-unsafe ; inline
M: input-stream stream-read-until read-until-loop ; inline
M: input-stream stream-readln "\n" swap stream-read-until drop ; inline
M: input-stream stream-contents* (stream-contents-by-length-or-block) ; inline
M: input-stream stream-seekable? drop f ; inline
M: input-stream stream-length drop f ; inline

M: output-stream stream-write '[ _ stream-write1 ] each ; inline
M: output-stream stream-flush drop ; inline
M: output-stream stream-nl CHAR: \n swap stream-write1 ; inline
M: output-stream stream-seekable? drop f ; inline
M: output-stream stream-length drop f ; inline

M: f stream-read1 drop f ; inline
M: f stream-read-unsafe 3drop 0 ; inline
M: f stream-read-until 2drop f f ; inline
M: f stream-read-partial-unsafe 3drop 0 ; inline
M: f stream-readln drop f ; inline
M: f stream-contents* drop f ; inline

M: f stream-write1 2drop ; inline
M: f stream-write 2drop ; inline
M: f stream-flush drop ; inline
M: f stream-nl drop ; inline
