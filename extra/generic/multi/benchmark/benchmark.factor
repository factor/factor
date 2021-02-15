! Copyright (C) 2021 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators formatting generic.multi io kernel math memory namespaces
sequences tools.time typed ;
IN: multi-generic.benchmark

MIXIN: thing

SINGLETON: paper    INSTANCE: paper thing
SINGLETON: scissors INSTANCE: scissors thing
SINGLETON: rock     INSTANCE: rock thing


! no-dispatch
: beats? ( obj1 obj2 -- ? )
    {
        { rock     [ scissors? [ t ] [ f ] if ] }
        { paper    [ rock?     [ t ] [ f ] if ] }
        { scissors [ paper?    [ t ] [ f ] if ] }
    } case ;


! multi-dispatch
GENERIC: md-beats? ( obj1 obj2 -- ? )

MM: md-beats? ( o: thing o: thing -- ? )  2drop f ;
MM: md-beats? ( o: paper o: scissors -- ? ) 2drop t ;
MM: md-beats? ( o: scissors o: rock -- ? )  2drop t ;
MM: md-beats? ( o: rock o: paper -- ? )  2drop t ;

: wrapped-md-beats? ( obj1 obj2 -- ? )
    md-beats? ;

! typed multi-dispatch
GENERIC: md-beats2? ( obj1 obj2 -- ? )

MM: md-beats2? ( o: paper o: scissors -- :boolean ) 2drop t ;
MM: md-beats2? ( o: scissors o: rock -- :boolean )  2drop t ;
MM: md-beats2? ( o: rock o: paper -- :boolean )  2drop t ;
MM: md-beats2? ( o: thing o: thing -- :boolean )  2drop f ;

: cartesian-times ( -- )
    { rock paper scissors } dup
    [ gc 2dup "%s %s:" printf '[ 1000000 [ _ _ md-beats? drop ] times ] benchmark time. ] cartesian-each ;

! multi-hook-dispatch
! GENERIC: mhd-beats? ( thing1 thing2 | -- ? )

! MM: mhd-beats? ( thing1: paper thing2: scissors | -- ? ) t ;
! MM: mhd-beats? ( thing1: scissors thing2: rock | -- ? ) t ;
! MM: mhd-beats? ( thing1: rock thing2: paper | -- ? ) t ;
! MM: mhd-beats? ( thing1: thing thing2: thing | -- ? ) f ;


! sigle-dispach
GENERIC: sd-beats? ( obj1 obj2 -- ? )

M: paper sd-beats? drop rock? [ t ] [ f ] if ;
M: scissors sd-beats? drop paper? [ t ] [ f ] if ;
M: rock sd-beats? drop scissors? [ t ] [ f ] if ;

: wrapped-sd-beats? ( obj1 obj2 -- ? )
    sd-beats? ;

! multi-sigle-dispach
GENERIC: smd-beats? ( obj1 obj2 -- ? )

MM: smd-beats? ( obj1 obj2: paper -- ? )    drop rock? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: scissors -- ? ) drop paper? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: rock -- ? )     drop scissors? [ t ] [ f ] if ;

SYMBOLS: thing1 thing2 ;


! sigle-hook-dispatch
HOOK: shd-beats? thing2 ( -- ? )

M: paper shd-beats? thing1 get rock? [ t ] [ f ] if ;
M: scissors shd-beats? thing1 get paper? [ t ] [ f ] if ;
M: rock shd-beats? thing1 get scissors? [ t ] [ f ] if ;


! sigle-spac-hook-multi-dispatch
! GENERIC: shmd-beats? ( thing2 | -- ? )

! MM: shmd-beats? ( thing2: scissors | -- ? ) thing1 get paper? [ t ] [ f ] if ;
! MM: shmd-beats? ( thing2: rock | -- ? ) thing1 get scissors? [ t ] [ f ] if ;
! MM: shmd-beats? ( thing2: paper | -- ? ) thing1 get rock? [ t ] [ f ] if ;

! tuple class dispatch

TUPLE: thingt ;
TUPLE: rockt < thingt ;
TUPLE: scissorst < thingt ;
TUPLE: papert < thingt ;

GENERIC: tsd-beats? ( obj1 obj2 -- ? )

M: papert tsd-beats? drop rockt? [ t ] [ f ] if ;
M: scissorst tsd-beats? drop papert? [ t ] [ f ] if ;
M: rockt tsd-beats? drop scissorst? [ t ] [ f ] if ;

: wrapped-tsd-beats? ( obj1 obj2 -- ? )
    tsd-beats? ;

GENERIC: tmd-beats? ( x x -- ? )
CONSTANT: rock1 T{ rockt f }
CONSTANT: paper1 T{ papert f }
CONSTANT: scissors1 T{ scissorst f }

MM: tmd-beats? ( o: thingt o: thingt -- ? )  2drop f ;
MM: tmd-beats? ( o: papert o: scissorst -- ? ) 2drop t ;
MM: tmd-beats? ( o: scissorst o: rockt -- ? )  2drop t ;
MM: tmd-beats? ( o: rockt o: papert -- ? )  2drop t ;

: wrapped-tmd-beats? ( obj1 obj2 -- ? )
    tmd-beats? ;

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


GENERIC: md-ln-beats? ( man man -- ? )

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


GENERIC: smd-ln-beats? ( man man -- ? )

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


CONSTANT: TIMES       1000,000
CONSTANT: COMBI-TIMES 1000,000
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
            paper paper       wrapped-sd-beats? drop
            paper scissors    wrapped-sd-beats? drop
            paper rock        wrapped-sd-beats? drop

            scissors paper    wrapped-sd-beats? drop
            scissors scissors wrapped-sd-beats? drop
            scissors rock     wrapped-sd-beats? drop

            rock paper        wrapped-sd-beats? drop
            rock scissors     wrapped-sd-beats? drop
            rock rock         wrapped-sd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "non-inlined sd:            %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper1 paper1       tsd-beats? drop
            paper1 scissors1    tsd-beats? drop
            paper1 rock1        tsd-beats? drop

            scissors1 paper1    tsd-beats? drop
            scissors1 scissors1 tsd-beats? drop
            scissors1 rock1     tsd-beats? drop

            rock1 paper1        tsd-beats? drop
            rock1 scissors1     tsd-beats? drop
            rock1 rock1         tsd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "tuple sd:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper1 paper1       wrapped-tsd-beats? drop
            paper1 scissors1    wrapped-tsd-beats? drop
            paper1 rock1        wrapped-tsd-beats? drop

            scissors1 paper1    wrapped-tsd-beats? drop
            scissors1 scissors1 wrapped-tsd-beats? drop
            scissors1 rock1     wrapped-tsd-beats? drop

            rock1 paper1        wrapped-tsd-beats? drop
            rock1 scissors1     wrapped-tsd-beats? drop
            rock1 rock1         wrapped-tsd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "non-inline tuple sd:             %.6f seconds (%.2f times slower)\n" printf

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
            paper paper       wrapped-md-beats? drop
            paper scissors    wrapped-md-beats? drop
            paper rock        wrapped-md-beats? drop

            scissors paper    wrapped-md-beats? drop
            scissors scissors wrapped-md-beats? drop
            scissors rock     wrapped-md-beats? drop

            rock paper        wrapped-md-beats? drop
            rock scissors     wrapped-md-beats? drop
            rock rock         wrapped-md-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "non-inlined md:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper1 paper1       tmd-beats? drop
            paper1 scissors1    tmd-beats? drop
            paper1 rock1        tmd-beats? drop

            scissors1 paper1    tmd-beats? drop
            scissors1 scissors1 tmd-beats? drop
            scissors1 rock1     tmd-beats? drop

            rock1 paper1        tmd-beats? drop
            rock1 scissors1     tmd-beats? drop
            rock1 rock1         tmd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "tuple md:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper1 paper1       wrapped-tmd-beats? drop
            paper1 scissors1    wrapped-tmd-beats? drop
            paper1 rock1        wrapped-tmd-beats? drop

            scissors1 paper1    wrapped-tmd-beats? drop
            scissors1 scissors1 wrapped-tmd-beats? drop
            scissors1 rock1     wrapped-tmd-beats? drop

            rock1 paper1        wrapped-tmd-beats? drop
            rock1 scissors1     wrapped-tmd-beats? drop
            rock1 rock1         wrapped-tmd-beats? drop
        ] times
    ] benchmark
    [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    "non-inline tuple md:             %.6f seconds (%.2f times slower)\n" printf

    gc
    [
        TIMES [
            paper paper       md-beats2? drop
            paper scissors    md-beats2? drop
            paper rock        md-beats2? drop

            scissors paper    md-beats2? drop
            scissors scissors md-beats2? drop
            scissors rock     md-beats2? drop

            rock paper        md-beats2? drop
            rock scissors     md-beats2? drop
            rock rock         md-beats2? drop
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

    ! gc
    ! [
    !     TIMES [
    !         paper    thing1 set
    !         paper    thing2 set mhd-beats? drop
    !         scissors thing2 set mhd-beats? drop
    !         rock     thing2 set mhd-beats? drop

    !         scissors thing1 set
    !         paper    thing2 set mhd-beats? drop
    !         scissors thing2 set mhd-beats? drop
    !         rock     thing2 set mhd-beats? drop

    !         rock     thing1 set
    !         paper    thing2 set mhd-beats? drop
    !         scissors thing2 set mhd-beats? drop
    !         rock     thing2 set mhd-beats? drop
    !     ] times
    ! ] benchmark
    ! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    ! "multi-hook-dispatch:        %.6f seconds (%.2f times slower)\n" printf

    ! gc
    ! [
    !     TIMES [
    !         paper    thing1 set
    !         paper    thing2 set shmd-beats? drop
    !         scissors thing2 set shmd-beats? drop
    !         rock     thing2 set shmd-beats? drop

    !         scissors thing1 set paper thing2 set shd-beats? drop scissors
    !         thing2 set shd-beats? drop rock thing2 set shd-beats? drop

    !         rock     thing1 set
    !         paper    thing2 set shmd-beats? drop
    !         scissors thing2 set shmd-beats? drop
    !         rock     thing2 set shmd-beats? drop
    !     ] times
    ! ] benchmark
    ! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
    ! "single-hook-multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

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
    "single-dispatch:            %.6f　seconds (reference)\n" printf

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

USE: strings

! GENERIC: partial-test ( x y -- z ) partial-inline
! MM: partial-test ( s: string s: string -- z ) append ;
! MM: partial-test ( n: fixnum n: fixnum -- z ) + ; inline
! MM: partial-test ( n: fixnum s: string -- z ) nip "num+" swap append ;
! MM: partial-test ( x y -- z ) 2drop f ;

! : partial-test-1 ( x y -- z )      partial-test ;
! : partial-test-2 ( y -- z )    "2" partial-test ;
! : partial-test-3 ( -- z )  "1" "2" partial-test ;

USE: math.private
GENERIC: partial+ ( a b -- c )  ! mathematical partial-inline inline
MM: partial+ ( n: fixnum n: fixnum -- c ) fixnum+ ;
MM: partial+ ( n: bignum n: bignum -- c ) bignum+ ;
MM: partial+ ( s: string s: string -- c ) append ;
MM: partial+ ( i: integer s: string -- c ) nip "int+" swap append ;

: math-partial-test-1 ( x y -- z )         partial+ ;
: math-partial-test-2 (   y -- z )      2  partial+ ;
: math-partial-test-3 (     -- z )  1   2  partial+ ;
: math-partial-test-4 (   y -- z )     "2" partial+ ;
: math-partial-test-5 (     -- z ) "1" "2" partial+ ;

USING: generic.multi math math.private typed ;

TYPED: add-floats ( a: float b: float -- c: float ) float+ ;
: add-somethings ( a b -- c ) + ; inline foldable flushable
: add-floats2 ( a b -- c ) float+ ;

GENERIC: partial-test ( x y -- z ) ! partial-inline ! It is not specified "mathematical".
MM: partial-test ( s: string s: string -- z: string ) append ;
MM: partial-test ( n: fixnum n: fixnum -- z: fixnum ) fixnum+ ;
MM: partial-test ( f: float f: float -- z: float ) float+ ;
MM: partial-test ( n: fixnum f: float -- z: float ) [ >float ] dip float+ ;
MM: partial-test ( x y -- z: float  ) 2drop 0.0 ;

GENERIC: float+float ( a b -- c )
MM: float+float ( a: float b: float -- c: float ) float+ ;
MM: float+float ( a: fixnum b: fixnum -- c: float ) fixnum+ >float ;

GENERIC: float+float2 ( a b -- c )
MM: float+float2 ( a: float b: float -- c ) float+ ;
MM: float+float2 ( a: fixnum b: fixnum -- c ) fixnum+ >float ;

: partial-test-1 ( x -- z ) 2.0 3.0 + partial-test ;
: partial-test-2 ( x -- z ) 2.0 3.0 add-floats partial-test ;
: partial-test-3 ( x -- z ) 2.0 3.0 add-somethings partial-test ;
: partial-test-4 ( x -- z ) 2.0 3.0 add-floats2 partial-test ;
: partial-test-5 ( x -- z ) 2.0 3.0 float+float partial-test ;
: partial-test-6 ( x -- z ) 2.0 3.0 float+float2 partial-test ;
: partial-test-7 ( x -- z ) 2.0 float+float 3.0 partial-test ;
: partial-test-8 ( x -- z ) 2.0 float+float2 3.0 partial-test ;
