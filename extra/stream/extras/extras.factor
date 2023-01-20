! Copyright (C) 2016 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel namespaces ;
IN: stream.extras

: stream-write1-flush ( str stream -- )
    [ stream-write1 ] [ stream-flush ] bi ; inline

: stream-write-flush ( str stream -- )
    [ stream-write ] [ stream-flush ] bi ; inline

: stream-print-flush ( str stream -- )
    [ stream-print ] [ stream-flush ] bi ; inline

: write1-flush ( str -- ) output-stream get stream-write1-flush ; inline
: write-flush ( str -- ) output-stream get stream-write-flush ; inline
: print-flush ( str -- ) output-stream get stream-print-flush ; inline

