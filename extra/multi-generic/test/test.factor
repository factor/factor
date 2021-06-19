! Copyright (C) 2021 KUSUMOTO Norio.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators formatting io kernel math math.ranges
memory multi-generic namespaces prettyprint quotations sequences
tools.test tools.time ;
IN: multi-generic.test

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


USE: strings

! MGENERIC: partial-test ( x y -- z ) partial-inline
! MM: partial-test ( :string :string -- z ) append ;
! MM: partial-test ( :fixnum :fixnum -- z ) + ; inline
! MM: partial-test ( :fixnum :string -- z ) nip "num+" swap append ;
! MM: partial-test ( x y -- z ) 2drop f ;

! : partial-test-1 ( x y -- z )      partial-test ;
! : partial-test-2 ( y -- z )    "2" partial-test ;
! : partial-test-3 ( -- z )  "1" "2" partial-test ;

USE: math.private
MGENERIC: partial+ ( a b -- c ) mathematical partial-inline inline
MM: partial+ ( :fixnum :fixnum -- c ) fixnum+ ;
MM: partial+ ( :bignum :bignum -- c ) bignum+ ;
MM: partial+ ( :string :string -- c ) append ;
MM: partial+ ( :integer :string -- c ) nip "int+" swap append ;

: math-partial-test-1 ( x y -- z )         partial+ ;
: math-partial-test-2 (   y -- z )      2  partial+ ;
: math-partial-test-3 (     -- z )  1   2  partial+ ;
: math-partial-test-4 (   y -- z )     "2" partial+ ;
: math-partial-test-5 (     -- z ) "1" "2" partial+ ;

USING: multi-generic math math.private typed ;

TYPED: add-floats ( a: float b: float -- c: float ) float+ ;
: add-somethings ( a b -- c ) + ; inline foldable flushable
: add-floats2 ( a b -- c ) float+ ;

MGENERIC: partial-test ( x y -- z ) partial-inline ! It is not specified "mathematical".
MM: partial-test ( :string :string -- z: string ) append ;
MM: partial-test ( :fixnum :fixnum -- z: fixnum ) fixnum+ ;
MM: partial-test ( :float :float -- z: float ) float+ ;
MM: partial-test ( :fixnum :float -- z: float ) [ >float ] dip float+ ;
MM: partial-test ( x y -- z: float  ) 2drop 0.0 ;

MGENERIC: float+float ( a b -- c ) partial-inline
MM: float+float ( a: float b: float -- c: float ) float+ ; inline
MM: float+float ( a: fixnum b: float -- c: float ) [ >float ] dip float+ ;

MGENERIC: float+float2 ( a b -- c )
MM: float+float2 ( a: float b: float -- c: float ) float+ ;
MM: float+float2 ( a: fixnum b: float -- c ) [ >float ] dip float+ ;

MGENERIC: push-floats ( -- x y )
MM: push-floats ( -- :float :float ) 1.0 2.0 ;

MGENERIC: push-floats2 ( -- x y )
MM: push-floats2 ( -- x y ) 1.0 2.0 ;

: partial-test-1 ( x -- z ) 2.0 3.0 + partial-test ;
: partial-test-2 ( x -- z ) 2.0 3.0 add-floats partial-test ;
: partial-test-3 ( x -- z ) 2.0 3.0 add-somethings partial-test ;
: partial-test-4 ( x -- z ) 2.0 3.0 float+float partial-test ;
: partial-test-5 ( x -- z ) 2.0 3.0 add-floats2 partial-test ;
: partial-test-6 ( x -- z ) 2.0 3.0 float+float2 partial-test ;
: partial-test-7 ( x -- z ) 2.0 float+float 3.0 partial-test ;
: partial-test-8 ( x -- z ) 2.0 float+float2 3.0 partial-test ;
: partial-test-9 ( -- z ) push-floats partial-test ;
: partial-test-10 ( -- z ) push-floats2 partial-test ;

TUPLE: test-tuple1 ;
TUPLE: test-tuple2 < test-tuple1 ;
TUPLE: test-tuple3 < test-tuple2 ;
TUPLE: test-tuple4 < test-tuple3 ;


MGENERIC: recompile-inline ( class1 class2 -- x ) partial-inline

MM: recompile-inline ( :test-tuple1 :test-tuple1 -- :string ) 2drop "test-tuple1" ;

: recompile-inline-test ( -- x ) T{ test-tuple3 } T{ test-tuple1 } recompile-inline ;

: recompile-inline-test2 ( x -- y ) T{ test-tuple1 } recompile-inline ;

recompile-inline-test .
T{ test-tuple3 } recompile-inline-test2 .

MM: recompile-inline ( :test-tuple2 :test-tuple1 -- :string ) 2drop "test-tuple2" ;

recompile-inline-test .
T{ test-tuple3 } recompile-inline-test2 .

MM: recompile-inline ( :test-tuple4 :test-tuple1 -- :string ) 2drop "test-tuple4" ;



