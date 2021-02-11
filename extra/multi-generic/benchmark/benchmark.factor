! Copyright (C) 2021 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators formatting io kernel math math.ranges
memory multi-generic namespaces prettyprint quotations sequences
tools.test tools.time ;
IN: multi-generic.benchmark

MIXIN: thing

SINGLETON: paper    INSTANCE: paper thing
SINGLETON: scissors INSTANCE: scissors thing
SINGLETON: rock     INSTANCE: rock thing

SYMBOLS: thing1 thing2 ;


! no-dispatch
: beats? ( obj1 obj2 -- ? )
    {
        { rock     [ scissors? [ t ] [ f ] if ] }
        { paper    [ rock?     [ t ] [ f ] if ] }
        { scissors [ paper?    [ t ] [ f ] if ] }
    } case ;


! multi-dispatch
MGENERIC: md-beats? ( obj1 obj2 -- ? )

MM: md-beats? ( :paper :scissors -- ? ) 2drop t ;
MM: md-beats? ( :scissors :rock -- ? )  2drop t ;
MM: md-beats? ( :rock :paper -- ? )  2drop t ;
MM: md-beats? ( :thing :thing -- ? )  2drop f ;


! typed multi-dispatch
MGENERIC: md-beats-t? ( obj1 obj2 -- ? )

MM: md-beats-t? ( :paper :scissors -- :boolean ) 2drop t ;
MM: md-beats-t? ( :scissors :rock -- :boolean )  2drop t ;
MM: md-beats-t? ( :rock :paper -- :boolean )  2drop t ;
MM: md-beats-t? ( :thing :thing -- :boolean )  2drop f ;


! multi-hook-dispatch
MGENERIC: mhd-beats? ( thing1 thing2 | -- ? )

MM: mhd-beats? ( thing1: paper thing2: scissors | -- ? ) t ;
MM: mhd-beats? ( thing1: scissors thing2: rock | -- ? ) t ;
MM: mhd-beats? ( thing1: rock thing2: paper | -- ? ) t ;
MM: mhd-beats? ( thing1: thing thing2: thing | -- ? ) f ;


! sigle-dispach
GENERIC: sd-beats? ( obj1 obj2 -- ? )

M: paper sd-beats? drop rock? [ t ] [ f ] if ;
M: scissors sd-beats? drop paper? [ t ] [ f ] if ;
M: rock sd-beats? drop scissors? [ t ] [ f ] if ;


! multi-sigle-dispach
MGENERIC: smd-beats? ( obj1 obj2 -- ? )

MM: smd-beats? ( obj1 obj2: paper -- ? )    drop rock? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: scissors -- ? ) drop paper? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: rock -- ? )     drop scissors? [ t ] [ f ] if ;


! sigle-hook-dispatch
HOOK: shd-beats? thing2 ( -- ? )

M: paper shd-beats? thing1 get rock? [ t ] [ f ] if ;
M: scissors shd-beats? thing1 get paper? [ t ] [ f ] if ;
M: rock shd-beats? thing1 get scissors? [ t ] [ f ] if ;


! sigle-spac-hook-multi-dispatch
MGENERIC: shmd-beats? ( thing2 | -- ? )

MM: shmd-beats? ( thing2: scissors | -- ? ) thing1 get paper? [ t ] [ f ] if ;
MM: shmd-beats? ( thing2: rock | -- ? ) thing1 get scissors? [ t ] [ f ] if ;
MM: shmd-beats? ( thing2: paper | -- ? ) thing1 get rock? [ t ] [ f ] if ;


MIXIN: man

SINGLETON: the-man-No.001 INSTANCE: the-man-No.001 man
SINGLETON: the-man-No.002 INSTANCE: the-man-No.002 man
SINGLETON: the-man-No.003 INSTANCE: the-man-No.003 man
SINGLETON: the-man-No.004 INSTANCE: the-man-No.004 man
SINGLETON: the-man-No.005 INSTANCE: the-man-No.005 man
SINGLETON: the-man-No.006 INSTANCE: the-man-No.006 man
SINGLETON: the-man-No.007 INSTANCE: the-man-No.007 man
SINGLETON: the-man-No.008 INSTANCE: the-man-No.008 man
SINGLETON: the-man-No.009 INSTANCE: the-man-No.009 man
SINGLETON: the-man-No.010 INSTANCE: the-man-No.010 man
SINGLETON: the-man-No.011 INSTANCE: the-man-No.011 man
SINGLETON: the-man-No.012 INSTANCE: the-man-No.012 man
SINGLETON: the-man-No.013 INSTANCE: the-man-No.013 man
SINGLETON: the-man-No.014 INSTANCE: the-man-No.014 man
SINGLETON: the-man-No.015 INSTANCE: the-man-No.015 man
SINGLETON: the-man-No.016 INSTANCE: the-man-No.016 man
SINGLETON: the-man-No.017 INSTANCE: the-man-No.017 man
SINGLETON: the-man-No.018 INSTANCE: the-man-No.018 man
SINGLETON: the-man-No.019 INSTANCE: the-man-No.019 man
SINGLETON: the-man-No.020 INSTANCE: the-man-No.020 man
SINGLETON: the-man-No.021 INSTANCE: the-man-No.021 man
SINGLETON: the-man-No.022 INSTANCE: the-man-No.022 man
SINGLETON: the-man-No.023 INSTANCE: the-man-No.023 man
SINGLETON: the-man-No.024 INSTANCE: the-man-No.024 man
SINGLETON: the-man-No.025 INSTANCE: the-man-No.025 man
SINGLETON: the-man-No.026 INSTANCE: the-man-No.026 man
SINGLETON: the-man-No.027 INSTANCE: the-man-No.027 man
SINGLETON: the-man-No.028 INSTANCE: the-man-No.028 man
SINGLETON: the-man-No.029 INSTANCE: the-man-No.029 man
SINGLETON: the-man-No.030 INSTANCE: the-man-No.030 man


GENERIC: sd-ln-beats? ( man1 man2 -- ? )

M: the-man-No.001 sd-ln-beats? 2drop t ;
M: the-man-No.002 sd-ln-beats? 2drop t ;
M: the-man-No.003 sd-ln-beats? 2drop t ;
M: the-man-No.004 sd-ln-beats? 2drop t ;
M: the-man-No.005 sd-ln-beats? 2drop t ;
M: the-man-No.006 sd-ln-beats? 2drop t ;
M: the-man-No.007 sd-ln-beats? 2drop t ;
M: the-man-No.008 sd-ln-beats? 2drop t ;
M: the-man-No.009 sd-ln-beats? 2drop t ;
M: the-man-No.010 sd-ln-beats? 2drop t ;
M: the-man-No.011 sd-ln-beats? 2drop t ;
M: the-man-No.012 sd-ln-beats? 2drop t ;
M: the-man-No.013 sd-ln-beats? 2drop t ;
M: the-man-No.014 sd-ln-beats? 2drop t ;
M: the-man-No.015 sd-ln-beats? 2drop t ;
M: the-man-No.016 sd-ln-beats? 2drop t ;
M: the-man-No.017 sd-ln-beats? 2drop t ;
M: the-man-No.018 sd-ln-beats? 2drop t ;
M: the-man-No.019 sd-ln-beats? 2drop t ;
M: the-man-No.020 sd-ln-beats? 2drop t ;
M: the-man-No.021 sd-ln-beats? 2drop t ;
M: the-man-No.022 sd-ln-beats? 2drop t ;
M: the-man-No.023 sd-ln-beats? 2drop t ;
M: the-man-No.024 sd-ln-beats? 2drop t ;
M: the-man-No.025 sd-ln-beats? 2drop t ;
M: the-man-No.026 sd-ln-beats? 2drop t ;
M: the-man-No.027 sd-ln-beats? 2drop t ;
M: the-man-No.028 sd-ln-beats? 2drop t ;
M: the-man-No.029 sd-ln-beats? 2drop t ;
M: the-man-No.030 sd-ln-beats? 2drop t ;


MGENERIC: md-ln-beats? ( man man -- ? )

MM: md-ln-beats? ( :man :the-man-No.001 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.002 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.003 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.004 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.005 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.006 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.007 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.008 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.009 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.010 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.011 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.012 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.013 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.014 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.015 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.016 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.017 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.018 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.019 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.020 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.021 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.022 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.023 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.024 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.025 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.026 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.027 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.028 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.029 -- ? ) 2drop t ;
MM: md-ln-beats? ( :man :the-man-No.030 -- ? ) 2drop t ;


MGENERIC: smd-ln-beats? ( man man -- ? )

MM: smd-ln-beats? ( man :the-man-No.001 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.002 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.003 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.004 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.005 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.006 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.007 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.008 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.009 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.010 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.011 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.012 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.013 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.014 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.015 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.016 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.017 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.018 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.019 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.020 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.021 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.022 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.023 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.024 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.025 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.026 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.027 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.028 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.029 -- ? ) 2drop t ;
MM: smd-ln-beats? ( man :the-man-No.030 -- ? ) 2drop t ;


CONSTANT: TIMES       100,000
CONSTANT: COMBI-TIMES 100,000
SYMBOL: no-dispatch-time
SYMBOL: ref

: bm ( -- )
    "\n"
    TIMES {
        { [ dup 1,000,000 >= ] [
              [ 1,000,000 / >integer ]
              [ 1,000,000 mod 1,000 / >integer ]
              [ 1,000 mod ]
              tri "%d,%03d,%03d" sprintf ] }
        { [ dup 1,000 >= ] [
              [ 1,000 / >integer ]
              [ 1,000 mod ]
              bi "%d,%03d" sprintf ] }
        [ "%d" sprintf ]
    } cond
    " repetitions of all combinations of rock-paper-scissors\n" 3append write

    gc
    [
        TIMES [
            paper paper       beats? drop
            paper scissors    beats? drop
            paper rock        beats? drop

            scissors paper    beats? drop
            scissors scissors beats? drop
            scissors rock     beats? drop

            rock paper        beats? drop
            rock scissors     beats? drop
            rock rock         beats? drop
        ] times
    ] benchmark dup no-dispatch-time set
    1.0e9 /
    "no-dispatch:                %.6f seconds (reference)\n" printf

    gc
    [
        TIMES [
            paper paper       sd-beats? drop
            paper scissors    sd-beats? drop
            paper rock        sd-beats? drop

            scissors paper    sd-beats? drop
            scissors scissors sd-beats? drop
            scissors rock     sd-beats? drop

            rock paper        sd-beats? drop
            rock scissors     sd-beats? drop
            rock rock         sd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-dispatch:            %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper paper       md-beats? drop
            paper scissors    md-beats? drop
            paper rock        md-beats? drop

            scissors paper    md-beats? drop
            scissors scissors md-beats? drop
            scissors rock     md-beats? drop

            rock paper        md-beats? drop
            rock scissors     md-beats? drop
            rock rock         md-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-dispatch:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper paper       md-beats-t? drop
            paper scissors    md-beats-t? drop
            paper rock        md-beats-t? drop

            scissors paper    md-beats-t? drop
            scissors scissors md-beats-t? drop
            scissors rock     md-beats-t? drop

            rock paper        md-beats-t? drop
            rock scissors     md-beats-t? drop
            rock rock         md-beats-t? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-dispatch (typed):     %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper paper       smd-beats? drop
            paper scissors    smd-beats? drop
            paper rock        smd-beats? drop

            scissors paper    smd-beats? drop
            scissors scissors smd-beats? drop
            scissors rock     smd-beats? drop

            rock paper        smd-beats? drop
            rock scissors     smd-beats? drop
            rock rock         smd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single spec multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper    thing1 set
            paper    thing2 set shd-beats? drop
            scissors thing2 set shd-beats? drop
            rock     thing2 set shd-beats? drop

            scissors thing1 set paper thing2 set shd-beats? drop scissors
            thing2 set shd-beats? drop rock thing2 set shd-beats? drop

            rock     thing1 set
            paper    thing2 set shd-beats? drop
            scissors thing2 set shd-beats? drop
            rock     thing2 set shd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-hook-dispatch:       %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper    thing1 set
            paper    thing2 set mhd-beats? drop
            scissors thing2 set mhd-beats? drop
            rock     thing2 set mhd-beats? drop

            scissors thing1 set
            paper    thing2 set mhd-beats? drop
            scissors thing2 set mhd-beats? drop
            rock     thing2 set mhd-beats? drop

            rock     thing1 set
            paper    thing2 set mhd-beats? drop
            scissors thing2 set mhd-beats? drop
            rock     thing2 set mhd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-hook-dispatch:        %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper    thing1 set
            paper    thing2 set shmd-beats? drop
            scissors thing2 set shmd-beats? drop
            rock     thing2 set shmd-beats? drop

            scissors thing1 set paper thing2 set shd-beats? drop scissors
            thing2 set shd-beats? drop rock thing2 set shd-beats? drop

            rock     thing1 set
            paper    thing2 set shmd-beats? drop
            scissors thing2 set shmd-beats? drop
            rock     thing2 set shmd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-hook-multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

    "\n"
    COMBI-TIMES {
        { [ dup 1,000,000 >= ] [
              [ 1,000,000 / >integer ]
              [ 1,000,000 mod 1,000 / >integer ]
              [ 1,000 mod ]
              tri "%d,%03d,%03d" sprintf ] }
        { [ dup 1,000 >= ] [
              [ 1,000 / >integer ]
              [ 1,000 mod ]
              bi "%d,%03d" sprintf ] }
        [ "%d" sprintf ]
    } cond
    " repetitions of the showdown of the all combinations of No.001 to No.005\n"
    3append write

    gc
    [
        COMBI-TIMES [
            the-man-No.001 the-man-No.001 sd-ln-beats? drop
            the-man-No.001 the-man-No.002 sd-ln-beats? drop
            the-man-No.001 the-man-No.003 sd-ln-beats? drop
            the-man-No.001 the-man-No.004 sd-ln-beats? drop
            the-man-No.001 the-man-No.005 sd-ln-beats? drop
            the-man-No.002 the-man-No.001 sd-ln-beats? drop
            the-man-No.002 the-man-No.002 sd-ln-beats? drop
            the-man-No.002 the-man-No.003 sd-ln-beats? drop
            the-man-No.002 the-man-No.004 sd-ln-beats? drop
            the-man-No.002 the-man-No.005 sd-ln-beats? drop
            the-man-No.003 the-man-No.001 sd-ln-beats? drop
            the-man-No.003 the-man-No.002 sd-ln-beats? drop
            the-man-No.003 the-man-No.003 sd-ln-beats? drop
            the-man-No.003 the-man-No.004 sd-ln-beats? drop
            the-man-No.003 the-man-No.005 sd-ln-beats? drop
            the-man-No.004 the-man-No.001 sd-ln-beats? drop
            the-man-No.004 the-man-No.002 sd-ln-beats? drop
            the-man-No.004 the-man-No.003 sd-ln-beats? drop
            the-man-No.004 the-man-No.004 sd-ln-beats? drop
            the-man-No.004 the-man-No.005 sd-ln-beats? drop
            the-man-No.005 the-man-No.001 sd-ln-beats? drop
            the-man-No.005 the-man-No.002 sd-ln-beats? drop
            the-man-No.005 the-man-No.003 sd-ln-beats? drop
            the-man-No.005 the-man-No.004 sd-ln-beats? drop
            the-man-No.005 the-man-No.005 sd-ln-beats? drop
        ] times
    ] benchmark dup ref namespaces:set
    1.0e9 /
    "single-dispatch:            %.6f seconds (reference)\n" printf

    gc
    [
        COMBI-TIMES [
            the-man-No.001 the-man-No.001 md-ln-beats? drop
            the-man-No.001 the-man-No.002 md-ln-beats? drop
            the-man-No.001 the-man-No.003 md-ln-beats? drop
            the-man-No.001 the-man-No.004 md-ln-beats? drop
            the-man-No.001 the-man-No.005 md-ln-beats? drop
            the-man-No.002 the-man-No.001 md-ln-beats? drop
            the-man-No.002 the-man-No.002 md-ln-beats? drop
            the-man-No.002 the-man-No.003 md-ln-beats? drop
            the-man-No.002 the-man-No.004 md-ln-beats? drop
            the-man-No.002 the-man-No.005 md-ln-beats? drop
            the-man-No.003 the-man-No.001 md-ln-beats? drop
            the-man-No.003 the-man-No.002 md-ln-beats? drop
            the-man-No.003 the-man-No.003 md-ln-beats? drop
            the-man-No.003 the-man-No.004 md-ln-beats? drop
            the-man-No.003 the-man-No.005 md-ln-beats? drop
            the-man-No.004 the-man-No.001 md-ln-beats? drop
            the-man-No.004 the-man-No.002 md-ln-beats? drop
            the-man-No.004 the-man-No.003 md-ln-beats? drop
            the-man-No.004 the-man-No.004 md-ln-beats? drop
            the-man-No.004 the-man-No.005 md-ln-beats? drop
            the-man-No.005 the-man-No.001 md-ln-beats? drop
            the-man-No.005 the-man-No.002 md-ln-beats? drop
            the-man-No.005 the-man-No.003 md-ln-beats? drop
            the-man-No.005 the-man-No.004 md-ln-beats? drop
            the-man-No.005 the-man-No.005 md-ln-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ ref get / ] bi
    "multi-dispatch:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        COMBI-TIMES [
            the-man-No.001 the-man-No.001 smd-ln-beats? drop
            the-man-No.001 the-man-No.002 smd-ln-beats? drop
            the-man-No.001 the-man-No.003 smd-ln-beats? drop
            the-man-No.001 the-man-No.004 smd-ln-beats? drop
            the-man-No.001 the-man-No.005 smd-ln-beats? drop
            the-man-No.002 the-man-No.001 smd-ln-beats? drop
            the-man-No.002 the-man-No.002 smd-ln-beats? drop
            the-man-No.002 the-man-No.003 smd-ln-beats? drop
            the-man-No.002 the-man-No.004 smd-ln-beats? drop
            the-man-No.002 the-man-No.005 smd-ln-beats? drop
            the-man-No.003 the-man-No.001 smd-ln-beats? drop
            the-man-No.003 the-man-No.002 smd-ln-beats? drop
            the-man-No.003 the-man-No.003 smd-ln-beats? drop
            the-man-No.003 the-man-No.004 smd-ln-beats? drop
            the-man-No.003 the-man-No.005 smd-ln-beats? drop
            the-man-No.004 the-man-No.001 smd-ln-beats? drop
            the-man-No.004 the-man-No.002 smd-ln-beats? drop
            the-man-No.004 the-man-No.003 smd-ln-beats? drop
            the-man-No.004 the-man-No.004 smd-ln-beats? drop
            the-man-No.004 the-man-No.005 smd-ln-beats? drop
            the-man-No.005 the-man-No.001 smd-ln-beats? drop
            the-man-No.005 the-man-No.002 smd-ln-beats? drop
            the-man-No.005 the-man-No.003 smd-ln-beats? drop
            the-man-No.005 the-man-No.004 smd-ln-beats? drop
            the-man-No.005 the-man-No.005 smd-ln-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ ref get / ] bi
    "single spec multi-dispatch: %.6f seconds (%.2f times slower)\n" printf
;



TUPLE: t-thing ;
TUPLE: t-paper    < t-thing ;
TUPLE: t-scissors < t-thing ;
TUPLE: t-rock     < t-thing ;

CONSTANT: c-t-paper    T{ t-paper }
CONSTANT: c-t-scissors T{ t-scissors }
CONSTANT: c-t-rock     T{ t-rock }

! no-dispatch
: beats2? ( obj1 obj2 -- ? )
    {
        { [ dup t-rock? ]     [ drop t-scissors? [ t ] [ f ] if ] }
        { [ dup t-paper? ]    [ drop t-rock?     [ t ] [ f ] if ] }
        { [ dup t-scissors? ] [ drop t-paper?    [ t ] [ f ] if ] }
        [ 2drop f ]
    } cond ;


! multi-dispatch
MGENERIC: md-beats2? ( obj1 obj2 -- ? )

MM: md-beats2? ( :t-paper :t-scissors -- ? ) 2drop t ;
MM: md-beats2? ( :t-scissors :t-rock -- ? )  2drop t ;
MM: md-beats2? ( :t-rock :t-paper -- ? )     2drop t ;
MM: md-beats2? ( :t-thing :t-thing -- ? )    2drop f ;


! typed multi-dispatch
MGENERIC: md-beats-t2? ( obj1 obj2 -- ? )

MM: md-beats-t2? ( :t-paper :t-scissors -- :boolean ) 2drop t ;
MM: md-beats-t2? ( :t-scissors :t-rock -- :boolean )  2drop t ;
MM: md-beats-t2? ( :t-rock :t-paper -- :boolean )     2drop t ;
MM: md-beats-t2? ( :t-thing :t-thing -- :boolean )    2drop f ;


! multi-hook-dispatch
MGENERIC: mhd-beats2? ( thing1 thing2 | -- ? )

MM: mhd-beats2? ( thing1: t-paper thing2: t-scissors | -- ? ) t ;
MM: mhd-beats2? ( thing1: t-scissors thing2: t-rock | -- ? ) t ;
MM: mhd-beats2? ( thing1: t-rock thing2: t-paper | -- ? ) t ;
MM: mhd-beats2? ( thing1: t-thing thing2: t-thing | -- ? ) f ;


! sigle-dispach
GENERIC: sd-beats2? ( obj1 obj2 -- ? )

M: t-paper sd-beats2? drop t-rock? [ t ] [ f ] if ;
M: t-scissors sd-beats2? drop t-paper? [ t ] [ f ] if ;
M: t-rock sd-beats2? drop t-scissors? [ t ] [ f ] if ;


! multi-sigle-dispach
MGENERIC: smd-beats2? ( obj1 obj2 -- ? )

MM: smd-beats2? ( obj1 obj2: t-paper -- ? )    drop t-rock? [ t ] [ f ] if ;
MM: smd-beats2? ( obj1 obj2: t-scissors -- ? ) drop t-paper? [ t ] [ f ] if ;
MM: smd-beats2? ( obj1 obj2: t-rock -- ? )     drop t-scissors? [ t ] [ f ] if ;


! sigle-hook-dispatch
HOOK: shd-beats2? thing2 ( -- ? )

M: t-paper shd-beats2? thing1 get t-rock? [ t ] [ f ] if ;
M: t-scissors shd-beats2? thing1 get t-paper? [ t ] [ f ] if ;
M: t-rock shd-beats2? thing1 get t-scissors? [ t ] [ f ] if ;


! sigle-spac-hook-multi-dispatch
MGENERIC: shmd-beats2? ( thing2 | -- ? )

MM: shmd-beats2? ( thing2: t-scissors | -- ? ) thing1 get t-paper? [ t ] [ f ] if ;
MM: shmd-beats2? ( thing2: t-rock | -- ? ) thing1 get t-scissors? [ t ] [ f ] if ;
MM: shmd-beats2? ( thing2: t-paper | -- ? ) thing1 get t-rock? [ t ] [ f ] if ;

: bm2 ( -- )
    "\n"
    TIMES {
        { [ dup 1,000,000 >= ] [
              [ 1,000,000 / >integer ]
              [ 1,000,000 mod 1,000 / >integer ]
              [ 1,000 mod ]
              tri "%d,%03d,%03d" sprintf ] }
        { [ dup 1,000 >= ] [
              [ 1,000 / >integer ]
              [ 1,000 mod ]
              bi "%d,%03d" sprintf ] }
        [ "%d" sprintf ]
    } cond
    " repetitions of all combinations of rock-paper-scissors (tuple version)\n" 3append write

    gc
    [
        TIMES [
            c-t-paper c-t-paper       beats2? drop
            c-t-paper c-t-scissors    beats2? drop
            c-t-paper c-t-rock        beats2? drop

            c-t-scissors c-t-paper    beats2? drop
            c-t-scissors c-t-scissors beats2? drop
            c-t-scissors c-t-rock     beats2? drop

            c-t-rock c-t-paper        beats2? drop
            c-t-rock c-t-scissors     beats2? drop
            c-t-rock c-t-rock         beats2? drop
        ] times
    ] benchmark dup no-dispatch-time set
    1.0e9 /
    "no-dispatch:                %.6f seconds (reference)\n" printf

    gc
    [
        TIMES [
            c-t-paper c-t-paper       sd-beats2? drop
            c-t-paper c-t-scissors    sd-beats2? drop
            c-t-paper c-t-rock        sd-beats2? drop

            c-t-scissors c-t-paper    sd-beats2? drop
            c-t-scissors c-t-scissors sd-beats2? drop
            c-t-scissors c-t-rock     sd-beats2? drop

            c-t-rock c-t-paper        sd-beats2? drop
            c-t-rock c-t-scissors     sd-beats2? drop
            c-t-rock c-t-rock         sd-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-dispatch:            %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper c-t-paper       md-beats2? drop
            c-t-paper c-t-scissors    md-beats2? drop
            c-t-paper c-t-rock        md-beats2? drop

            c-t-scissors c-t-paper    md-beats2? drop
            c-t-scissors c-t-scissors md-beats2? drop
            c-t-scissors c-t-rock     md-beats2? drop

            c-t-rock c-t-paper        md-beats2? drop
            c-t-rock c-t-scissors     md-beats2? drop
            c-t-rock c-t-rock         md-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-dispatch:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper c-t-paper       md-beats-t2? drop
            c-t-paper c-t-scissors    md-beats-t2? drop
            c-t-paper c-t-rock        md-beats-t2? drop

            c-t-scissors c-t-paper    md-beats-t2? drop
            c-t-scissors c-t-scissors md-beats-t2? drop
            c-t-scissors c-t-rock     md-beats-t2? drop

            c-t-rock c-t-paper        md-beats-t2? drop
            c-t-rock c-t-scissors     md-beats-t2? drop
            c-t-rock c-t-rock         md-beats-t2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-dispatch (typed):     %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper c-t-paper       smd-beats2? drop
            c-t-paper c-t-scissors    smd-beats2? drop
            c-t-paper c-t-rock        smd-beats2? drop

            c-t-scissors c-t-paper    smd-beats2? drop
            c-t-scissors c-t-scissors smd-beats2? drop
            c-t-scissors c-t-rock     smd-beats2? drop

            c-t-rock c-t-paper        smd-beats2? drop
            c-t-rock c-t-scissors     smd-beats2? drop
            c-t-rock c-t-rock         smd-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single spec multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper    thing1 set
            c-t-paper    thing2 set shd-beats2? drop
            c-t-scissors thing2 set shd-beats2? drop
            c-t-rock     thing2 set shd-beats2? drop

            c-t-scissors thing1 set c-t-paper thing2 set shd-beats2? drop c-t-scissors
            thing2 set shd-beats2? drop c-t-rock thing2 set shd-beats2? drop

            c-t-rock     thing1 set
            c-t-paper    thing2 set shd-beats2? drop
            c-t-scissors thing2 set shd-beats2? drop
            c-t-rock     thing2 set shd-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-hook-dispatch:       %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper    thing1 set
            c-t-paper    thing2 set mhd-beats2? drop
            c-t-scissors thing2 set mhd-beats2? drop
            c-t-rock     thing2 set mhd-beats2? drop

            c-t-scissors thing1 set
            c-t-paper    thing2 set mhd-beats2? drop
            c-t-scissors thing2 set mhd-beats2? drop
            c-t-rock     thing2 set mhd-beats2? drop

            c-t-rock     thing1 set
            c-t-paper    thing2 set mhd-beats2? drop
            c-t-scissors thing2 set mhd-beats2? drop
            c-t-rock     thing2 set mhd-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "multi-hook-dispatch:        %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            c-t-paper    thing1 set
            c-t-paper    thing2 set shmd-beats2? drop
            c-t-scissors thing2 set shmd-beats2? drop
            c-t-rock     thing2 set shmd-beats2? drop

            c-t-scissors thing1 set c-t-paper thing2 set shd-beats2? drop c-t-scissors
            thing2 set shd-beats2? drop c-t-rock thing2 set shd-beats2? drop

            c-t-rock     thing1 set
            c-t-paper    thing2 set shmd-beats2? drop
            c-t-scissors thing2 set shmd-beats2? drop
            c-t-rock     thing2 set shmd-beats2? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "single-hook-multi-dispatch: %.6f seconds (%.2f times slower)\n" printf
;