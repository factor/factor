! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators concurrency.mailboxes io
kernel make math math.parser math.text.english sequences
splitting threads ;
IN: benchmark.chameneos-redux

SYMBOLS: red yellow blue ;

ERROR: bad-color-pair pair ;

TUPLE: creature n color count self-count mailbox ;

TUPLE: meeting-place count mailbox ;

: <meeting-place> ( count -- meeting-place )
    meeting-place new
        swap >>count
        <mailbox> >>mailbox ;

: <creature> ( n color -- creature )
    creature new
        swap >>color
        swap >>n
        0 >>count
        0 >>self-count
        <mailbox> >>mailbox ;

: make-creatures ( colors -- seq )
    [ length <iota> ] [ ] bi [ <creature> ] 2map ;

: complement-color ( color1 color2 -- color3 )
    2dup = [ drop ] [
        2array {
            { { red yellow } [ blue ] }
            { { red blue } [ yellow ] }
            { { yellow red } [ blue ] }
            { { yellow blue } [ red ] }
            { { blue red } [ yellow ] }
            { { blue yellow } [ red ] }
            [ bad-color-pair ]
        } case
    ] if ;

: color-string ( color1 color2 -- string )
    [
        [ [ name>> ] bi@ " + " glue % " -> " % ]
        [ complement-color name>> % ] 2bi
    ] "" make ;

: print-color-table ( -- )
    { blue red yellow } dup
    '[ _ '[ color-string print ] with each ] each ;

: try-meet ( meeting-place creature -- )
    over count>> 0 < [
        2drop
    ] [
        [ swap mailbox>> mailbox-put ]
        [ nip mailbox>> mailbox-get drop ]
        [ try-meet ] 2tri
    ] if ;

: creature-meeting ( seq -- )
    first2 {
        [ [ [ 1 + ] change-count ] bi@ 2drop ]
        [ 2dup = [ [ 1 + ] change-self-count ] when 2drop ]
        [ [ [ color>> ] bi@ complement-color ] [ [ color<< ] bi-curry@ bi ] 2bi ]
        [ [ mailbox>> f swap mailbox-put ] bi@ ]
    } 2cleave ;

: run-meeting-place ( meeting-place -- )
    [ 1 - ] change-count
    dup count>> 0 < [
        mailbox>> mailbox-get-all
        [ f swap mailbox>> mailbox-put ] each
    ] [
        [ mailbox>> 2 swap '[ _ mailbox-get ] replicate creature-meeting ]
        [ run-meeting-place ] bi
    ] if ;

: number>chameneos-string ( n -- string )
    number>string string>digits [ number>text ] { } map-as join-words ;

: chameneos-redux ( n colors -- )
    [ <meeting-place> ] [ make-creatures ] bi*
    {
        [ nip nl bl [ bl ] [ color>> name>> write ] interleave nl ]
        [ [ '[ _ _ try-meet ] in-thread ] with each ]
        [ drop run-meeting-place ]

        [ nip [ [ count>> number>string write bl ] [ self-count>> number>text write nl ] bi ] each ]
        [ nip [ count>> ] map-sum bl number>chameneos-string print ]
    } 2cleave ;

! 6000000 for shootout, too slow right now

: chameneos-redux-benchmark ( -- )
    print-color-table
    60000 [
        { blue red yellow } chameneos-redux
    ] [
        { blue red yellow red yellow blue red yellow red blue } chameneos-redux
    ] bi ;

MAIN: chameneos-redux-benchmark
