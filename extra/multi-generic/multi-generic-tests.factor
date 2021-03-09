! Copyright (C) 2021 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators formatting io kernel math math.ranges
memory multi-generic namespaces prettyprint quotations sequences
tools.test tools.time ;
IN: multi-generic.tests

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


{ f t f  f f t  t f f } [
    paper paper       beats?
    paper scissors    beats?
    paper rock        beats?

    scissors paper    beats?
    scissors scissors beats?
    scissors rock     beats?

    rock paper        beats?
    rock scissors     beats?
    rock rock         beats?
] unit-test


! multi-dispatch
MGENERIC: md-beats? ( obj1 obj2 -- ? )

MM:: md-beats? ( obj1: paper obj2: scissors -- ?: boolean ) obj1 obj2 2drop t ;
MM:: md-beats? ( :scissors :rock -- ?: boolean ) t ;
MM:: md-beats? ( :rock :paper -- ?: boolean ) t ;
MM:: md-beats? ( :thing :thing -- ?: boolean ) f ;


{ f t f  f f t  t f f } [
    paper paper       md-beats?
    paper scissors    md-beats?
    paper rock        md-beats?

    scissors paper    md-beats?
    scissors scissors md-beats?
    scissors rock     md-beats?

    rock paper        md-beats?
    rock scissors     md-beats?
    rock rock         md-beats?
] unit-test


! multi-hook-dispatch
MGENERIC: mhd-beats? ( thing1 thing2 | -- ? )

MM: mhd-beats? ( thing1: paper thing2: scissors | -- ? ) t ;
MM: mhd-beats? ( thing1: scissors thing2: rock | -- ? ) t ;
MM: mhd-beats? ( thing1: rock thing2: paper | -- ? ) t ;
MM: mhd-beats? ( thing1: thing thing2: thing | -- ? ) f ;


{ f t f  f f t  t f f } [
    paper    thing1 set
    paper    thing2 set mhd-beats?
    scissors thing2 set mhd-beats?
    rock     thing2 set mhd-beats?

    scissors thing1 set
    paper    thing2 set mhd-beats?
    scissors thing2 set mhd-beats?
    rock     thing2 set mhd-beats?

    rock     thing1 set
    paper    thing2 set mhd-beats?
    scissors thing2 set mhd-beats?
    rock     thing2 set mhd-beats?
] unit-test


! sigle-dispach
GENERIC: sd-beats? ( obj1 obj2 -- ? )

M: paper sd-beats? drop rock? [ t ] [ f ] if ;
M: scissors sd-beats? drop paper? [ t ] [ f ] if ;
M: rock sd-beats? drop scissors? [ t ] [ f ] if ;


{ f t f  f f t  t f f } [
    paper paper       sd-beats?
    paper scissors    sd-beats?
    paper rock        sd-beats?

    scissors paper    sd-beats?
    scissors scissors sd-beats?
    scissors rock     sd-beats?

    rock paper        sd-beats?
    rock scissors     sd-beats?
    rock rock         sd-beats?
] unit-test

! multi-sigle-dispach
MGENERIC: smd-beats? ( obj1 obj2 -- ? )

MM: smd-beats? ( obj1 obj2: paper -- ? )    drop rock? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: scissors -- ? ) drop paper? [ t ] [ f ] if ;
MM: smd-beats? ( obj1 obj2: rock -- ? )     drop scissors? [ t ] [ f ] if ;

{
    f t f  f f t  t f f
    f t f  f f t  t f f
} [
    2 [
        paper paper       smd-beats?
        paper scissors    smd-beats?
        paper rock        smd-beats?

        scissors paper    smd-beats?
        scissors scissors smd-beats?
        scissors rock     smd-beats?

        rock paper        smd-beats?
        rock scissors     smd-beats?
        rock rock         smd-beats?
    ] times
] unit-test

{
    f t f  f f t  t f f
    f t f  f f t  t f f
} [
    2 [
        paper paper       smd-beats?
        paper scissors    smd-beats?
        paper rock        smd-beats?

        scissors paper    smd-beats?
        scissors scissors smd-beats?
        scissors rock     smd-beats?

        rock paper        smd-beats?
        rock scissors     smd-beats?
        rock rock         smd-beats?
    ] times
] unit-test


! sigle-hook-dispatch
HOOK: shd-beats? thing2 ( -- ? )

M: paper shd-beats? thing1 get rock? [ t ] [ f ] if ;
M: scissors shd-beats? thing1 get paper? [ t ] [ f ] if ;
M: rock shd-beats? thing1 get scissors? [ t ] [ f ] if ;


{ f t f  f f t  t f f } [
    paper    thing1 set
    paper    thing2 set shd-beats?
    scissors thing2 set shd-beats?
    rock     thing2 set shd-beats?

    scissors thing1 set
    paper    thing2 set shd-beats?
    scissors thing2 set shd-beats?
    rock     thing2 set shd-beats?

    rock     thing1 set
    paper    thing2 set shd-beats?
    scissors thing2 set shd-beats?
    rock     thing2 set shd-beats?
] unit-test

! sigle-spac-hook-multi-dispatch
MGENERIC: shmd-beats? ( thing2 | -- ? )

MM: shmd-beats? ( thing2: scissors | -- ? ) thing1 get paper? [ t ] [ f ] if ;
MM: shmd-beats? ( thing2: rock | -- ? ) thing1 get scissors? [ t ] [ f ] if ;
MM: shmd-beats? ( thing2: paper | -- ? ) thing1 get rock? [ t ] [ f ] if ;

{ f t f  f f t  t f f } [
    paper    thing1 set
    paper    thing2 set shmd-beats?
    scissors thing2 set shmd-beats?
    rock     thing2 set shmd-beats?

    scissors thing1 set
    paper    thing2 set shmd-beats?
    scissors thing2 set shmd-beats?
    rock     thing2 set shmd-beats?

    rock     thing1 set
    paper    thing2 set shmd-beats?
    scissors thing2 set shmd-beats?
    rock     thing2 set shmd-beats?
] unit-test




! multi-dispatch cached version
MGENERIC: cached-md-beats? ( obj1 obj2 -- ? ) cached-multi ! inline

MM:: cached-md-beats? ( obj1: paper obj2: scissors -- ?: boolean ) obj1 obj2 2drop t ;
MM:: cached-md-beats? ( :scissors :rock -- ?: boolean ) t ;
MM:: cached-md-beats? ( :rock :paper -- ?: boolean ) t ;
MM:: cached-md-beats? ( :thing :thing -- ?: boolean ) f ;


{ f t f  f f t  t f f } [
    paper paper       cached-md-beats?
    paper scissors    cached-md-beats?
    paper rock        cached-md-beats?

    scissors paper    cached-md-beats?
    scissors scissors cached-md-beats?
    scissors rock     cached-md-beats?

    rock paper        cached-md-beats?
    rock scissors     cached-md-beats?
    rock rock         cached-md-beats?
] unit-test


MGENERIC: hook-beats-stack? ( thing1 | thing-s1 thing-s2 -- ? )

MM: hook-beats-stack? ( thing1: paper    | :rock :rock -- ? )
    2drop t ;

MM: hook-beats-stack? ( thing1: scissors | :paper :paper -- ? )
    2drop t ;

MM: hook-beats-stack? ( thing1: rock     | :scissors :scissors -- ? )
    2drop t ;

MM: hook-beats-stack? ( thing1: thing    | :thing :thing -- ? )
    2drop f ;

{ t f } [
    paper thing1 set    rock rock hook-beats-stack?
    scissors thing1 set rock rock hook-beats-stack?
] unit-test


MGENERIC: hook-beats-stack?-2 ( thing1 thing2 | a: thing b: thing -- ? )

MM: hook-beats-stack?-2 ( thing1: paper thing2: paper | a: rock b: rock -- ? )
    2drop t ;

MM: hook-beats-stack?-2 ( thing1: scissors thing2: scissors |
                          a: paper b: paper -- ? )
    2drop t ;

MM: hook-beats-stack?-2 ( thing1: rock thing2: rock |
                          a: scissors b: scissors -- ? )
    2drop t ;

MM: hook-beats-stack?-2 ( thing1: thing thing2: thing |
                          a: thing b: thing -- ? )
    2drop f ;

{ t f } [
    paper thing1 set paper thing2 set    rock rock hook-beats-stack?
    scissors thing1 set paper thing2 set rock rock hook-beats-stack?
] unit-test


! MGENERIC: dispatch#1 ( a *b* c -- d )

! MM: dispatch#1 ( a: object b: integer c: object -- d ) 3drop "integer" ;
! MM: dispatch#1 ( a b: object c -- d ) 3drop "Something other than integer" ;

! { "integer" "Something other than integer" "integer" } [
!     1 2 3 dispatch#1
!     1 2.0 3 dispatch#1
!     1.0 2 3.0 dispatch#1
! ] unit-test


! SYMBOL: ref

! MIXIN: man

! SINGLETON: the-man-No.001 INSTANCE: the-man-No.001 man
! SINGLETON: the-man-No.002 INSTANCE: the-man-No.002 man
! SINGLETON: the-man-No.003 INSTANCE: the-man-No.003 man
! SINGLETON: the-man-No.004 INSTANCE: the-man-No.004 man
! SINGLETON: the-man-No.005 INSTANCE: the-man-No.005 man
! SINGLETON: the-man-No.006 INSTANCE: the-man-No.006 man
! SINGLETON: the-man-No.007 INSTANCE: the-man-No.007 man
! SINGLETON: the-man-No.008 INSTANCE: the-man-No.008 man
! SINGLETON: the-man-No.009 INSTANCE: the-man-No.009 man
! SINGLETON: the-man-No.010 INSTANCE: the-man-No.010 man
! SINGLETON: the-man-No.011 INSTANCE: the-man-No.011 man
! SINGLETON: the-man-No.012 INSTANCE: the-man-No.012 man
! SINGLETON: the-man-No.013 INSTANCE: the-man-No.013 man
! SINGLETON: the-man-No.014 INSTANCE: the-man-No.014 man
! SINGLETON: the-man-No.015 INSTANCE: the-man-No.015 man
! SINGLETON: the-man-No.016 INSTANCE: the-man-No.016 man
! SINGLETON: the-man-No.017 INSTANCE: the-man-No.017 man
! SINGLETON: the-man-No.018 INSTANCE: the-man-No.018 man
! SINGLETON: the-man-No.019 INSTANCE: the-man-No.019 man
! SINGLETON: the-man-No.020 INSTANCE: the-man-No.020 man
! SINGLETON: the-man-No.021 INSTANCE: the-man-No.021 man
! SINGLETON: the-man-No.022 INSTANCE: the-man-No.022 man
! SINGLETON: the-man-No.023 INSTANCE: the-man-No.023 man
! SINGLETON: the-man-No.024 INSTANCE: the-man-No.024 man
! SINGLETON: the-man-No.025 INSTANCE: the-man-No.025 man
! SINGLETON: the-man-No.026 INSTANCE: the-man-No.026 man
! SINGLETON: the-man-No.027 INSTANCE: the-man-No.027 man
! SINGLETON: the-man-No.028 INSTANCE: the-man-No.028 man
! SINGLETON: the-man-No.029 INSTANCE: the-man-No.029 man
! SINGLETON: the-man-No.030 INSTANCE: the-man-No.030 man


! GENERIC: sd-ln-beats? ( man1 man2 -- ? )

! M: the-man-No.001 sd-ln-beats? 2drop t ;
! M: the-man-No.002 sd-ln-beats? 2drop t ;
! M: the-man-No.003 sd-ln-beats? 2drop t ;
! M: the-man-No.004 sd-ln-beats? 2drop t ;
! M: the-man-No.005 sd-ln-beats? 2drop t ;
! M: the-man-No.006 sd-ln-beats? 2drop t ;
! M: the-man-No.007 sd-ln-beats? 2drop t ;
! M: the-man-No.008 sd-ln-beats? 2drop t ;
! M: the-man-No.009 sd-ln-beats? 2drop t ;
! M: the-man-No.010 sd-ln-beats? 2drop t ;
! M: the-man-No.011 sd-ln-beats? 2drop t ;
! M: the-man-No.012 sd-ln-beats? 2drop t ;
! M: the-man-No.013 sd-ln-beats? 2drop t ;
! M: the-man-No.014 sd-ln-beats? 2drop t ;
! M: the-man-No.015 sd-ln-beats? 2drop t ;
! M: the-man-No.016 sd-ln-beats? 2drop t ;
! M: the-man-No.017 sd-ln-beats? 2drop t ;
! M: the-man-No.018 sd-ln-beats? 2drop t ;
! M: the-man-No.019 sd-ln-beats? 2drop t ;
! M: the-man-No.020 sd-ln-beats? 2drop t ;
! M: the-man-No.021 sd-ln-beats? 2drop t ;
! M: the-man-No.022 sd-ln-beats? 2drop t ;
! M: the-man-No.023 sd-ln-beats? 2drop t ;
! M: the-man-No.024 sd-ln-beats? 2drop t ;
! M: the-man-No.025 sd-ln-beats? 2drop t ;
! M: the-man-No.026 sd-ln-beats? 2drop t ;
! M: the-man-No.027 sd-ln-beats? 2drop t ;
! M: the-man-No.028 sd-ln-beats? 2drop t ;
! M: the-man-No.029 sd-ln-beats? 2drop t ;
! M: the-man-No.030 sd-ln-beats? 2drop t ;


! MGENERIC: md-ln-beats? ( man man -- ? )

! MM: md-ln-beats? ( :man :the-man-No.001 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.002 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.003 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.004 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.005 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.006 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.007 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.008 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.009 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.010 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.011 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.012 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.013 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.014 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.015 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.016 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.017 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.018 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.019 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.020 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.021 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.022 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.023 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.024 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.025 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.026 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.027 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.028 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.029 -- ? ) 2drop t ;
! MM: md-ln-beats? ( :man :the-man-No.030 -- ? ) 2drop t ;


! MGENERIC: smd-ln-beats? ( man man -- ? )

! MM: smd-ln-beats? ( man :the-man-No.001 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.002 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.003 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.004 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.005 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.006 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.007 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.008 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.009 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.010 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.011 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.012 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.013 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.014 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.015 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.016 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.017 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.018 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.019 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.020 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.021 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.022 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.023 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.024 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.025 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.026 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.027 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.028 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.029 -- ? ) 2drop t ;
! MM: smd-ln-beats? ( man :the-man-No.030 -- ? ) 2drop t ;


! MGENERIC: my-plus ( a b -- c ) mathematical

! USING: math.private ;
! MM: my-plus ( a: fixnum b: fixnum -- c ) fixnum+ ;
! MM: my-plus ( a: bignum b: bignum -- c ) bignum+ ;
! MM: my-plus ( a: float b: float -- c ) float+ ;

! USE: math.complex.private
! MM: my-plus ( a: complex b: complex -- c ) [ my-plus ] complex-op ;

! USE: math.ratios.private
! MM: my-plus ( a: ratio b: ratio -- c ) scale+d [ my-plus ] [ / ] bi* ;

! USE: strings
! MM: my-plus ( a: string b: string -- c ) append ;

! USE: unicode
! MM: my-plus ( a: character b: string -- c ) swap 1array >string prepend ;

! USE: classes

! { 3 3.0 3.0 3 bignum 1+1/6 1.0 C{ 2.0 -1 } "1 + 2.0 = 3.0" "1.0 + 2 = 3.0" } [
!     1 2 my-plus
!     1.0 2 my-plus
!     1 2.0 my-plus
!     1 2 >bignum my-plus dup class-of
!     1/2 2/3 my-plus
!     0.5 1/2 my-plus
!     C{ 0 -1 } 2.0 my-plus
!     "1 + 2.0 = " "3.0" my-plus
!     CHAR: 1 ".0 + 2 = 3.0" my-plus
! ] unit-test


MGENERIC: md-beats2? ( obj1 obj2 -- ? )

MM:: md-beats2? ( obj1: paper obj2: scissors -- ? )
    obj1 "scissors beats %s!\n" printf t ;

MM:: md-beats2? ( obj1: scissors obj2: rock -- ? )
    obj2 "%s beats scissors!\n" printf t ;

MM:: md-beats2? ( o1: rock o2: paper -- ? )
    o2 o1 "%s beats %s!\n" printf t ;

MM:: md-beats2? ( thing1: thing thing2: thing -- ? )
    thing2 thing1 "%s doesn't beat %s.\n" printf f ;


{ f t f  f f t  t f f } [
    paper paper       md-beats2?
    paper scissors    md-beats2?
    paper rock        md-beats2?

    scissors paper    md-beats2?
    scissors scissors md-beats2?
    scissors rock     md-beats2?

    rock paper        md-beats2?
    rock scissors     md-beats2?
    rock rock         md-beats2?
] unit-test


! MGENERIC: smd-beats2? ( obj1 obj2 -- ? )

! MM:: smd-beats2? ( obj1 obj2: paper -- ? )
!     obj1 rock? [ t ] [ f ] if obj1 "%s vs. paper\n" printf ;

! MM:: smd-beats2? ( obj1 obj2: scissors -- ? )
!     obj1 paper? [ t ] [ f ] if obj1 obj2 "%s vs. %s\n" printf ;

! MM:: smd-beats2? ( o1 o2: rock -- ? )
!     o1 scissors? [ t ] [ f ] if o1 "%s vs. rock\n" printf ;

! { f t f  f f t  t f f } [
!     paper paper       smd-beats2?
!     paper scissors    smd-beats2?
!     paper rock        smd-beats2?

!     scissors paper    smd-beats2?
!     scissors scissors smd-beats2?
!     scissors rock     smd-beats2?

!     rock paper        smd-beats2?
!     rock scissors     smd-beats2?
!     rock rock         smd-beats2?
! ] unit-test


! TUPLE: test-tuple1 ;
! TUPLE: test-tuple2 < test-tuple1 ;
! TUPLE: test-tuple3 < test-tuple2 ;

! MGENERIC: next-method-test ( class -- who-i-am )

! MM: next-method-test ( class: test-tuple3 -- who-i-am )
!     call-next-multi-method "a nice subclass of " prepend ;

! MM: next-method-test ( class: test-tuple2 -- who-i-am )
!     call-next-multi-method "a cool subclass of " prepend ;

! MM: next-method-test ( class: test-tuple1 -- who-i-am )
!     drop "test-tuple1" ;

! {
!     "test-tuple1"
!     "a cool subclass of test-tuple1"
!     "a nice subclass of a cool subclass of test-tuple1"
! } [
!     test-tuple1 new next-method-test
!     test-tuple2 new next-method-test
!     test-tuple3 new next-method-test
! ] unit-test


! USE: strings

! GENERIC: my-generic ( obj -- obj' )
! M: integer my-generic 1 + ;
! M: string my-generic "!" append ; inline
! : my-sd-program ( -- x ) 0 my-generic ;

! MGENERIC: my-mgeneric ( obj -- obj' )
! MM: my-mgeneric ( obj: integer -- obj' ) 1 + ;
! MM: my-mgeneric ( obj: string  -- obj' ) "!" append ; inline

! : my-md-program ( -- x ) 0 my-mgeneric ;



! CONSTANT: TIMES       100,000
! CONSTANT: COMBI-TIMES 100,000
! SYMBOL: no-dispatch-time

! "\n"
! TIMES {
!     { [ dup 1,000,000 >= ] [
!           [ 1,000,000 / >integer ]
!           [ 1,000,000 mod 1,000 / >integer ]
!           [ 1,000 mod ]
!           tri "%d,%03d,%03d" sprintf ] }
!     { [ dup 1,000 >= ] [
!           [ 1,000 / >integer ]
!           [ 1,000 mod ]
!           bi "%d,%03d" sprintf ] }
!     [ "%d" sprintf ]
! } cond
! " repetitions of all combinations of rock-paper-scissors\n" 3append write

! gc
! [
!     TIMES [
!         paper paper       beats? drop
!         paper scissors    beats? drop
!         paper rock        beats? drop

!         scissors paper    beats? drop
!         scissors scissors beats? drop
!         scissors rock     beats? drop

!         rock paper        beats? drop
!         rock scissors     beats? drop
!         rock rock         beats? drop
!     ] times
! ] benchmark dup no-dispatch-time set
! 1.0e9 /
! "no-dispatch:                %.6f seconds (reference)\n" printf

! gc
! [
!     TIMES [
!         paper paper       sd-beats? drop
!         paper scissors    sd-beats? drop
!         paper rock        sd-beats? drop

!         scissors paper    sd-beats? drop
!         scissors scissors sd-beats? drop
!         scissors rock     sd-beats? drop

!         rock paper        sd-beats? drop
!         rock scissors     sd-beats? drop
!         rock rock         sd-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
! "single-dispatch:            %.6f seconds (%.2f times slower)\n" printf

! gc
! [
!     TIMES [
!         paper paper       md-beats? drop
!         paper scissors    md-beats? drop
!         paper rock        md-beats? drop

!         scissors paper    md-beats? drop
!         scissors scissors md-beats? drop
!         scissors rock     md-beats? drop

!         rock paper        md-beats? drop
!         rock scissors     md-beats? drop
!         rock rock         md-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
! "multi-dispatch:             %.6f seconds (%.2f times slower)\n" printf

! gc
! [
!     TIMES [
!         paper paper       smd-beats? drop
!         paper scissors    smd-beats? drop
!         paper rock        smd-beats? drop

!         scissors paper    smd-beats? drop
!         scissors scissors smd-beats? drop
!         scissors rock     smd-beats? drop

!         rock paper        smd-beats? drop
!         rock scissors     smd-beats? drop
!         rock rock         smd-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
! "single spec multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

! gc
! [
!     TIMES [
!         paper    thing1 set
!         paper    thing2 set shd-beats? drop
!         scissors thing2 set shd-beats? drop
!         rock     thing2 set shd-beats? drop

!         scissors thing1 set paper thing2 set shd-beats? drop scissors
!         thing2 set shd-beats? drop rock thing2 set shd-beats? drop

!         rock     thing1 set
!         paper    thing2 set shd-beats? drop
!         scissors thing2 set shd-beats? drop
!         rock     thing2 set shd-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ no-dispatch-time get / ] bi
! "single-hook-dispatch:       %.6f seconds (%.2f times slower)\n" printf

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

! "\n"
! COMBI-TIMES {
!     { [ dup 1,000,000 >= ] [
!           [ 1,000,000 / >integer ]
!           [ 1,000,000 mod 1,000 / >integer ]
!           [ 1,000 mod ]
!           tri "%d,%03d,%03d" sprintf ] }
!     { [ dup 1,000 >= ] [
!           [ 1,000 / >integer ]
!           [ 1,000 mod ]
!           bi "%d,%03d" sprintf ] }
!     [ "%d" sprintf ]
! } cond
! " repetitions of the showdown of the all combinations of No.001 to No.005\n"
! 3append write

! gc
! [
!     COMBI-TIMES [
!         the-man-No.001 the-man-No.001 sd-ln-beats? drop
!         the-man-No.001 the-man-No.002 sd-ln-beats? drop
!         the-man-No.001 the-man-No.003 sd-ln-beats? drop
!         the-man-No.001 the-man-No.004 sd-ln-beats? drop
!         the-man-No.001 the-man-No.005 sd-ln-beats? drop
!         the-man-No.002 the-man-No.001 sd-ln-beats? drop
!         the-man-No.002 the-man-No.002 sd-ln-beats? drop
!         the-man-No.002 the-man-No.003 sd-ln-beats? drop
!         the-man-No.002 the-man-No.004 sd-ln-beats? drop
!         the-man-No.002 the-man-No.005 sd-ln-beats? drop
!         the-man-No.003 the-man-No.001 sd-ln-beats? drop
!         the-man-No.003 the-man-No.002 sd-ln-beats? drop
!         the-man-No.003 the-man-No.003 sd-ln-beats? drop
!         the-man-No.003 the-man-No.004 sd-ln-beats? drop
!         the-man-No.003 the-man-No.005 sd-ln-beats? drop
!         the-man-No.004 the-man-No.001 sd-ln-beats? drop
!         the-man-No.004 the-man-No.002 sd-ln-beats? drop
!         the-man-No.004 the-man-No.003 sd-ln-beats? drop
!         the-man-No.004 the-man-No.004 sd-ln-beats? drop
!         the-man-No.004 the-man-No.005 sd-ln-beats? drop
!         the-man-No.005 the-man-No.001 sd-ln-beats? drop
!         the-man-No.005 the-man-No.002 sd-ln-beats? drop
!         the-man-No.005 the-man-No.003 sd-ln-beats? drop
!         the-man-No.005 the-man-No.004 sd-ln-beats? drop
!         the-man-No.005 the-man-No.005 sd-ln-beats? drop
!     ] times
! ] benchmark dup ref namespaces:set
! 1.0e9 /
! "single-dispatch:            %.6f　seconds (reference)\n" printf

! gc
! [
!     COMBI-TIMES [
!         the-man-No.001 the-man-No.001 md-ln-beats? drop
!         the-man-No.001 the-man-No.002 md-ln-beats? drop
!         the-man-No.001 the-man-No.003 md-ln-beats? drop
!         the-man-No.001 the-man-No.004 md-ln-beats? drop
!         the-man-No.001 the-man-No.005 md-ln-beats? drop
!         the-man-No.002 the-man-No.001 md-ln-beats? drop
!         the-man-No.002 the-man-No.002 md-ln-beats? drop
!         the-man-No.002 the-man-No.003 md-ln-beats? drop
!         the-man-No.002 the-man-No.004 md-ln-beats? drop
!         the-man-No.002 the-man-No.005 md-ln-beats? drop
!         the-man-No.003 the-man-No.001 md-ln-beats? drop
!         the-man-No.003 the-man-No.002 md-ln-beats? drop
!         the-man-No.003 the-man-No.003 md-ln-beats? drop
!         the-man-No.003 the-man-No.004 md-ln-beats? drop
!         the-man-No.003 the-man-No.005 md-ln-beats? drop
!         the-man-No.004 the-man-No.001 md-ln-beats? drop
!         the-man-No.004 the-man-No.002 md-ln-beats? drop
!         the-man-No.004 the-man-No.003 md-ln-beats? drop
!         the-man-No.004 the-man-No.004 md-ln-beats? drop
!         the-man-No.004 the-man-No.005 md-ln-beats? drop
!         the-man-No.005 the-man-No.001 md-ln-beats? drop
!         the-man-No.005 the-man-No.002 md-ln-beats? drop
!         the-man-No.005 the-man-No.003 md-ln-beats? drop
!         the-man-No.005 the-man-No.004 md-ln-beats? drop
!         the-man-No.005 the-man-No.005 md-ln-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ ref get / ] bi
! "multi-dispatch:             %.6f seconds (%.2f times slower)\n" printf

! gc
! [
!     COMBI-TIMES [
!         the-man-No.001 the-man-No.001 smd-ln-beats? drop
!         the-man-No.001 the-man-No.002 smd-ln-beats? drop
!         the-man-No.001 the-man-No.003 smd-ln-beats? drop
!         the-man-No.001 the-man-No.004 smd-ln-beats? drop
!         the-man-No.001 the-man-No.005 smd-ln-beats? drop
!         the-man-No.002 the-man-No.001 smd-ln-beats? drop
!         the-man-No.002 the-man-No.002 smd-ln-beats? drop
!         the-man-No.002 the-man-No.003 smd-ln-beats? drop
!         the-man-No.002 the-man-No.004 smd-ln-beats? drop
!         the-man-No.002 the-man-No.005 smd-ln-beats? drop
!         the-man-No.003 the-man-No.001 smd-ln-beats? drop
!         the-man-No.003 the-man-No.002 smd-ln-beats? drop
!         the-man-No.003 the-man-No.003 smd-ln-beats? drop
!         the-man-No.003 the-man-No.004 smd-ln-beats? drop
!         the-man-No.003 the-man-No.005 smd-ln-beats? drop
!         the-man-No.004 the-man-No.001 smd-ln-beats? drop
!         the-man-No.004 the-man-No.002 smd-ln-beats? drop
!         the-man-No.004 the-man-No.003 smd-ln-beats? drop
!         the-man-No.004 the-man-No.004 smd-ln-beats? drop
!         the-man-No.004 the-man-No.005 smd-ln-beats? drop
!         the-man-No.005 the-man-No.001 smd-ln-beats? drop
!         the-man-No.005 the-man-No.002 smd-ln-beats? drop
!         the-man-No.005 the-man-No.003 smd-ln-beats? drop
!         the-man-No.005 the-man-No.004 smd-ln-beats? drop
!         the-man-No.005 the-man-No.005 smd-ln-beats? drop
!     ] times
! ] benchmark
! [ 1.0e9 / ] [ ref get / ] bi
! "single spec multi-dispatch: %.6f seconds (%.2f times slower)\n" printf

! USING: kernel.private compiler.tree.debugger ;

! MGENERIC: method-inlining-1 ( x -- y )
! MM: method-inlining-1 ( :string -- y ) length ;
! MM: method-inlining-1 ( :fixnum -- y ) log2 ;

! [ method-inlining-1 ] optimized.
! [ { string } declare method-inlining-1 ] optimized.
! [ { fixnum } declare method-inlining-1 ] optimized.
! [ { array } declare method-inlining-1 ] optimized.


! MGENERIC: method-inlining-2 ( x y -- z )
! MM: method-inlining-2 ( :string :string -- z ) append ;
! MM: method-inlining-2 ( :fixnum :fixnum -- z ) + ; inline

! [ method-inlining-2 ] optimized.
! [ { string string } declare method-inlining-2 ] optimized.
! [ { fixnum fixnum } declare method-inlining-2 ] optimized.
! [ { string fixnum } declare method-inlining-2 ] optimized.

! { "12" 3 } [
!     "1" "2" method-inlining-2
!     1 2 method-inlining-2
! ] unit-test

! MGENERIC: method-inlining-3 ( a b c -- z )
! MM: method-inlining-3 ( a b: string c: string -- z ) [ drop ] 2dip append ;
! MM: method-inlining-3 ( a b: fixnum c: fixnum -- z ) [ drop ] 2dip + ;
! MM: method-inlining-3 ( a b c -- z ) 3drop "default" ;

!    1 2 3 method-inlining-3 .
!    1 "2" "3" method-inlining-3 .
!    1 2 "3" method-inlining-3 .
!    "1" "2" 3 method-inlining-3 .

! [ method-inlining-3 ] optimized.
! [ { string string } declare method-inlining-3 ] optimized.
! [ { object string string } declare method-inlining-3 ] optimized.
! [ { fixnum string string } declare method-inlining-3 ] optimized.
! [ { string string string } declare method-inlining-3 ] optimized.
! [ { fixnum fixnum } declare method-inlining-3 ] optimized.
! [ { object fixnum fixnum } declare method-inlining-3 ] optimized.
! [ { fixnum fixnum fixnum } declare method-inlining-3 ] optimized.
! [ { string fixnum fixnum } declare method-inlining-3 ] optimized.
! [ { fixnum fixnum string } declare method-inlining-3 ] optimized.
! [ { string array fixnum } declare method-inlining-3 ] optimized.

! [ my-plus ] optimized.
! [ { fixnum fixnum } declare my-plus ] optimized.
! [ { float float } declare my-plus ] optimized.
! [ { bignum fixnum } declare my-plus ] optimized.
! [ { string string } declare my-plus ] optimized.
! [ { character string } declare my-plus ] optimized.
! [ { character character } declare my-plus ] optimized.

! [ method-inlining-2 ] optimized.
! [ { string string } declare method-inlining-2 ] optimized.
! [ { fixnum fixnum } declare method-inlining-2 ] optimized.
! [ { string fixnum } declare method-inlining-2 ] optimized.


! ! USING: multi-generic kernel.private compiler.tree.debugger ;

! MGENERIC: partial-1 ( x y -- z ) partial-inline
! MM: partial-1 ( :string :string -- z ) append ;
! MM: partial-1 ( :fixnum :fixnum -- z ) fixnum+ ; inline
! MM: partial-1 ( x y -- z ) 2drop f ;

! [ partial-1 ] optimized.
! [ { string string } declare partial-1 ] optimized.
! [ { string } declare partial-1 ] optimized.
! [ { fixnum fixnum } declare partial-1 ] optimized.
! [ { fixnum } declare partial-1 ] optimized.

! SYMBOL: box1 "2" box1 set
! SYMBOL: box2 2   box2 set
! { "12" 3 } [
!     "1" box1 get partial-1
!     1   box2 get partial-1
! ] unit-test

! MGENERIC: test2 ( a b -- c )
! MM: test2 ( :fixnum b -- c ) 2drop 1 ;
! MM: test2 ( :integer b -- c ) 2drop 2 ;
! MM: test2 ( a :array -- c ) 2drop "3" ;

! MGENERIC: partial+ ( a b -- c ) mathematical partial-inline
! MM: partial+ ( :fixnum :fixnum -- c: fixnum ) fixnum+ ;
! MM: partial+ ( :bignum :bignum -- c: bignum ) bignum+ ;
! MM: partial+ ( :string :string -- c: string ) append ;
! MM: partial+ ( :integer :string -- c: string ) "int+" nip swap append ;
