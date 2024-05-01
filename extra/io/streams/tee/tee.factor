! Copyright (C) 2024 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors destructors io io.files kernel math namespaces
sequences ;

IN: io.streams.tee

TUPLE: tee-stream in out ;

C: <tee-stream> tee-stream

INSTANCE: tee-stream input-stream

<PRIVATE

: >tee-stream< ( tee-stream -- in out )
    [ in>> ] [ out>> ] bi ; inline

MACRO: tee1 ( read-quot write-quot -- quot )
    '[ >tee-stream< _ [ [ over _ dip ] [ stream-flush ] bi ] bi* ] ;

MACRO: tee2 ( read-quot write-quot -- quot )
    '[ >tee-stream< _ [ [ 2over _ 2dip ] [ stream-flush ] bi ] bi* ] ;

PRIVATE>

M: tee-stream stream-read1
    [ stream-read1 ] [ stream-write1 ] tee1 ;

M:: tee-stream stream-read-unsafe ( n buf stream -- count )
    n buf stream
    [ stream-read-unsafe ]
    [ '[ buf swap head _ stream-write ] unless-zero ] tee1 ;

M:: tee-stream stream-read-partial-unsafe ( n buf stream -- count )
    n buf stream
    [ stream-read-partial-unsafe ]
    [ '[ buf swap head _ stream-write ] unless-zero ] tee1 ;

M: tee-stream stream-readln
    [ stream-readln ]
    [ '[ _ [ stream-write ] [ stream-nl ] bi ] when* ] tee1 ;

M: tee-stream stream-read-until
    >tee-stream<
    [ stream-read-until ]
    [
        dup '[
            [ [ _ stream-write ] when* ]
            [ [ _ stream-write1 ] when* ] bi*
        ] 2over [ call ] 2dip
    ] bi* ;

M: tee-stream stream-contents*
    [ stream-contents* ] [ stream-write ] tee1 ;

M: tee-stream dispose
    >tee-stream< [ dispose ] bi@ ;

: with-tee-stream ( input output quot -- )
    [ <tee-stream> ] dip with-input-stream ; inline

: tee-to-file-writer ( path encoding -- )
    [ input-stream ] 2dip '[ _ _ <file-writer> <tee-stream> ] change ;

: tee-to-file-appender ( path encoding -- )
    [ input-stream ] 2dip '[ _ _ <file-appender> <tee-stream> ] change ;

: tee-to-stdout ( -- )
    input-stream [ output-stream get-global <tee-stream> ] change ;

: tee-to-stderr ( -- )
    input-stream [ error-stream get-global <tee-stream> ] change ;
