! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: io namespaces ;
IN: io.errors

: ebl ( -- ) error-stream get stream-bl ;
: enl ( -- ) error-stream get stream-nl ; inline
: ewrite ( str -- ) error-stream get stream-write ; inline
: ewrite1 ( elt -- ) error-stream get stream-write1 ; inline
: eprint ( str -- ) error-stream get stream-print ; inline
: eflush ( -- ) error-stream get stream-flush ; inline
