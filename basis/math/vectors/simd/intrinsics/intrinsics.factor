! Copyright (C) 2009 Slava Pestov, Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data combinators cpu.architecture
grouping kernel libc math math.libm math.order ranges
sequences sequences.cords sequences.generalizations sequences.private
sequences.unrolled sequences.unrolled.private specialized-arrays
vocabs ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS:
    c:char c:short c:int c:longlong
    c:uchar c:ushort c:uint c:ulonglong
    c:float c:double ;
IN: math.vectors.simd.intrinsics

! Word props are added later
: (simd-positive) ( x -- y ) ;

<PRIVATE

: >bitwise-vector-rep ( rep -- rep' )
    {
        { float-4-rep    [ uint-4-rep      ] }
        { double-2-rep   [ ulonglong-2-rep ] }
        [ ]
    } case ; foldable

: >uint-vector-rep ( rep -- rep' )
    {
        { longlong-2-rep [ ulonglong-2-rep ] }
        { int-4-rep      [ uint-4-rep      ] }
        { short-8-rep    [ ushort-8-rep    ] }
        { char-16-rep    [ uchar-16-rep    ] }
        [ ]
    } case ; foldable

: >int-vector-rep ( rep -- rep' )
    {
        { float-4-rep  [ int-4-rep      ] }
        { double-2-rep [ longlong-2-rep ] }
    } case ; foldable

: >float-vector-rep ( rep -- rep' )
    {
        { int-4-rep      [ float-4-rep  ] }
        { longlong-2-rep [ double-2-rep ] }
    } case ; foldable

: byte>rep-array ( byte-array rep -- array )
    {
        { char-16-rep      [ 16 c:char <c-direct-array>      ] }
        { uchar-16-rep     [ 16 c:uchar <c-direct-array>     ] }
        { short-8-rep      [  8 c:short <c-direct-array>     ] }
        { ushort-8-rep     [  8 c:ushort <c-direct-array>    ] }
        { int-4-rep        [  4 c:int <c-direct-array>       ] }
        { uint-4-rep       [  4 c:uint <c-direct-array>      ] }
        { longlong-2-rep   [  2 c:longlong <c-direct-array>  ] }
        { ulonglong-2-rep  [  2 c:ulonglong <c-direct-array> ] }
        { float-4-rep      [  4 c:float <c-direct-array>     ] }
        { double-2-rep     [  2 c:double <c-direct-array>    ] }
    } case ; inline

: >rep-array ( seq rep -- array )
    {
        { char-16-rep      [ c:char >c-array      ] }
        { uchar-16-rep     [ c:uchar >c-array     ] }
        { short-8-rep      [ c:short >c-array     ] }
        { ushort-8-rep     [ c:ushort >c-array    ] }
        { int-4-rep        [ c:int >c-array       ] }
        { uint-4-rep       [ c:uint >c-array      ] }
        { longlong-2-rep   [ c:longlong >c-array  ] }
        { ulonglong-2-rep  [ c:ulonglong >c-array ] }
        { float-4-rep      [ c:float >c-array     ] }
        { double-2-rep     [ c:double >c-array    ] }
    } case ; inline

: <rep-array> ( rep -- array )
    {
        { char-16-rep      [ 16 c:char (c-array)      ] }
        { uchar-16-rep     [ 16 c:uchar (c-array)     ] }
        { short-8-rep      [  8 c:short (c-array)     ] }
        { ushort-8-rep     [  8 c:ushort (c-array)    ] }
        { int-4-rep        [  4 c:int (c-array)       ] }
        { uint-4-rep       [  4 c:uint (c-array)      ] }
        { longlong-2-rep   [  2 c:longlong (c-array)  ] }
        { ulonglong-2-rep  [  2 c:ulonglong (c-array) ] }
        { float-4-rep      [  4 c:float (c-array)     ] }
        { double-2-rep     [  2 c:double (c-array)    ] }
    } case ; inline

: rep-tf-values ( rep -- t f )
    float-vector-rep? [ -1 bits>double 0.0 ] [ -1 0 ] if ;

: 2byte>rep-array ( a b rep -- a' b' )
    '[ _ byte>rep-array ] bi@ ; inline

: components-map ( a rep quot -- c )
    [ [ byte>rep-array ] [ rep-length ] bi ] dip unrolled-map-unsafe underlying>> ; inline
: components-2map ( a b rep quot -- c )
    [ [ 2byte>rep-array ] [ rep-length ] bi ] dip unrolled-2map-unsafe underlying>> ; inline
: components-reduce ( a rep quot -- x )
    [ byte>rep-array [ ] ] dip map-reduce ; inline

: bitwise-components-map ( a rep quot -- c )
    [ >bitwise-vector-rep [ byte>rep-array ] [ rep-length ] bi ] dip
    unrolled-map-unsafe underlying>> ; inline
: bitwise-components-2map ( a b rep quot -- c )
    [ >bitwise-vector-rep [ 2byte>rep-array ] [ rep-length ] bi ] dip
    unrolled-2map-unsafe underlying>> ; inline
: bitwise-components-reduce ( a rep quot -- x )
    [ >bitwise-vector-rep byte>rep-array [ ] ] dip map-reduce ; inline
: bitwise-components-reduce* ( a rep identity quot -- x )
    [ >bitwise-vector-rep byte>rep-array ] 2dip reduce ; inline

:: (vshuffle) ( a elts rep -- c )
    a rep byte>rep-array :> a'
    rep <rep-array> :> c'
    elts rep rep-length [| from to |
        from rep rep-length 1 - bitand
           a' nth-unsafe
        to c' set-nth-unsafe
    ] unrolled-each-index-unsafe
    c' underlying>> ; inline

:: (vshuffle2) ( a b elts rep -- c )
    a rep byte>rep-array :> a'
    b rep byte>rep-array :> b'
    a' b' cord-append :> ab'
    rep <rep-array> :> c'
    elts rep rep-length [| from to |
        from rep rep-length dup + 1 - bitand
           ab' nth-unsafe
        to c' set-nth-unsafe
    ] unrolled-each-index-unsafe
    c' underlying>> ; inline

GENERIC: native/ ( x y -- x/y )

M: integer native/ /i ; inline
M: float native/ /f ; inline

: (vgetmask) ( a rep -- b )
    0 [ [ 1 shift ] [ zero? 0 1 ? ] bi* bitor ] bitwise-components-reduce* ; inline

PRIVATE>

: (simd-v+)                ( a b rep -- c ) [ + ] components-2map ;
: (simd-v-)                ( a b rep -- c ) [ - ] components-2map ;
: (simd-vneg)              ( a   rep -- c ) [ neg ] components-map ;
:: (simd-v+-)              ( a b rep -- c )
    a b rep 2byte>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    0  rep rep-length [ 1 -  2 <range> ] [ 2 /i ] bi [| n |
        n     a' nth-unsafe n     b' nth-unsafe -
        n     c' set-nth-unsafe

        n 1 + a' nth-unsafe n 1 + b' nth-unsafe +
        n 1 + c' set-nth-unsafe
    ] unrolled-each-unsafe
    c' underlying>> ;
: (simd-vs+)               ( a b rep -- c )
    dup rep-component-type '[ + _ c:c-type-clamp ] components-2map ;
: (simd-vs-)               ( a b rep -- c )
    dup rep-component-type '[ - _ c:c-type-clamp ] components-2map ;
: (simd-vs*)               ( a b rep -- c )
    dup rep-component-type '[ * _ c:c-type-clamp ] components-2map ;
: (simd-v*)                ( a b rep -- c ) [ * ] components-2map ;
: (simd-v*high)            ( a b rep -- c )
    dup rep-component-type c:heap-size -8 * '[ * _ shift ] components-2map ;
:: (simd-v*hs+)            ( a b rep -- c )
    rep { char-16-rep uchar-16-rep } member-eq?
    [ uchar-16-rep char-16-rep ]
    [ rep rep ] if :> ( a-rep b-rep )
    b-rep widen-vector-rep signed-rep :> wide-rep
    wide-rep rep-component-type :> wide-type
    a a-rep byte>rep-array 2 <groups> :> a'
    b b-rep byte>rep-array 2 <groups> :> b'
    a' b' rep rep-length 2 /i [
        [ [ first  ] bi@ * ]
        [ [ second ] bi@ * ] 2bi +
        wide-type c:c-type-clamp
    ] wide-rep <rep-array> unrolled-2map-as-unsafe underlying>> ;
: (simd-v/)                ( a b rep -- c ) [ native/ ] components-2map ;
: (simd-vavg)              ( a b rep -- c )
    [ + dup integer? [ 1 + -1 shift ] [ 0.5 * ] if ] components-2map ;
: (simd-vmin)              ( a b rep -- c ) [ min ] components-2map ;
: (simd-vmax)              ( a b rep -- c ) [ max ] components-2map ;
! XXX
: (simd-vdot)              ( a b rep -- n )
    [ 2byte>rep-array [ [ first ] bi@ * ] 2keep ] keep
    1 swap rep-length [a..b) [ '[ _ swap nth-unsafe ] bi@ * + ] 2with each ;
: (simd-vsqrt)             ( a   rep -- c ) [ fsqrt ] components-map ;
: (simd-vsad)              ( a b rep -- c ) 2byte>rep-array [ - abs ] [ + ] 2map-reduce ;
: (simd-sum)               ( a   rep -- n ) [ + ] components-reduce ;
: (simd-vabs)              ( a   rep -- c ) [ abs ] components-map ;
: (simd-vbitand)           ( a b rep -- c ) [ bitand ] bitwise-components-2map ;
: (simd-vbitandn)          ( a b rep -- c ) [ [ bitnot ] dip bitand ] bitwise-components-2map ;
: (simd-vbitor)            ( a b rep -- c ) [ bitor ] bitwise-components-2map ;
: (simd-vbitxor)           ( a b rep -- c ) [ bitxor ] bitwise-components-2map ;
: (simd-vbitnot)           ( a   rep -- c ) [ bitnot ] bitwise-components-map ;
: (simd-vand)              ( a b rep -- c ) [ bitand ] bitwise-components-2map ;
: (simd-vandn)             ( a b rep -- c ) [ [ bitnot ] dip bitand ] bitwise-components-2map ;
: (simd-vor)               ( a b rep -- c ) [ bitor ] bitwise-components-2map ;
: (simd-vxor)              ( a b rep -- c ) [ bitxor ] bitwise-components-2map ;
: (simd-vnot)              ( a   rep -- c ) [ bitnot ] bitwise-components-map ;
: (simd-vlshift)           ( a n rep -- c ) swap '[ _ shift ] bitwise-components-map ;
: (simd-vrshift)           ( a n rep -- c ) swap '[ _ neg shift ] bitwise-components-map ;
! XXX
: (simd-hlshift)           ( a n rep -- c )
    drop head-slice* 16 0 pad-head ;
! XXX
: (simd-hrshift)           ( a n rep -- c )
    drop tail-slice 16 0 pad-tail ;
: (simd-vshuffle-elements) ( a n rep -- c ) [ rep-length 0 pad-tail ] keep (vshuffle) ;
: (simd-vshuffle2-elements) ( a b n rep -- c ) [ rep-length 0 pad-tail ] keep (vshuffle2) ;
: (simd-vshuffle-bytes)    ( a b rep -- c ) drop uchar-16-rep (vshuffle) ;
:: (simd-vmerge-head)      ( a b rep -- c )
    a b rep 2byte>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    rep rep-length 2 /i [| n |
        n a' nth-unsafe n 2 *     c' set-nth-unsafe
        n b' nth-unsafe n 2 * 1 + c' set-nth-unsafe
    ] unrolled-each-integer
    c' underlying>> ;
:: (simd-vmerge-tail)      ( a b rep -- c )
    a b rep 2byte>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    rep rep-length 2 /i :> len
    len [| n |
        n len + a' nth-unsafe n 2 *     c' set-nth-unsafe
        n len + b' nth-unsafe n 2 * 1 + c' set-nth-unsafe
    ] unrolled-each-integer
    c' underlying>> ;
: (simd-v<=)               ( a b rep -- c )
    dup rep-tf-values '[ <= _ _ ? ] components-2map ;
: (simd-v<)                ( a b rep -- c )
    dup rep-tf-values '[ <  _ _ ? ] components-2map ;
: (simd-v=)                ( a b rep -- c )
    dup rep-tf-values '[ =  _ _ ? ] components-2map ;
: (simd-v>)                ( a b rep -- c )
    dup rep-tf-values '[ >  _ _ ? ] components-2map ;
: (simd-v>=)               ( a b rep -- c )
    dup rep-tf-values '[ >= _ _ ? ] components-2map ;
: (simd-vunordered?)       ( a b rep -- c )
    dup rep-tf-values '[ unordered? _ _ ? ] components-2map ;
: (simd-vany?)             ( a   rep -- ? ) [ bitor  ] bitwise-components-reduce zero? not ;
: (simd-vall?)             ( a   rep -- ? ) [ bitand ] bitwise-components-reduce zero? not ;
: (simd-vnone?)            ( a   rep -- ? ) [ bitor  ] bitwise-components-reduce zero?     ;
: (simd-vgetmask)          ( a   rep -- n )
    { float-4-rep double-2-rep } member?
    [ uint-4-rep (vgetmask) ] [ uchar-16-rep (vgetmask) ] if ;
: (simd-v>float)           ( a   rep -- c )
    [ [ byte>rep-array ] [ rep-length ] bi [ >float ] ]
    [ >float-vector-rep <rep-array> ] bi unrolled-map-as-unsafe underlying>> ;
: (simd-v>integer)         ( a   rep -- c )
    [ [ byte>rep-array ] [ rep-length ] bi [ >integer ] ]
    [ >int-vector-rep <rep-array> ] bi unrolled-map-as-unsafe underlying>> ;
: (simd-vpack-signed)      ( a b rep -- c )
    [ [ 2byte>rep-array cord-append ] [ rep-length 2 * ] bi ]
    [ narrow-vector-rep [ <rep-array> ] [ rep-component-type ] bi ] bi
    '[ _ c:c-type-clamp ] swap unrolled-map-as-unsafe underlying>> ;
: (simd-vpack-unsigned)    ( a b rep -- c )
    [ [ 2byte>rep-array cord-append ] [ rep-length 2 * ] bi ]
    [ narrow-vector-rep >uint-vector-rep [ <rep-array> ] [ rep-component-type ] bi ] bi
    '[ _ c:c-type-clamp ] swap unrolled-map-as-unsafe underlying>> ;
: (simd-vunpack-head)      ( a   rep -- c )
    [ byte>rep-array ] [ widen-vector-rep [ rep-length ] [ '[ _ >rep-array ] ] bi ] bi
    [ head-slice ] dip call( a' -- c' ) underlying>> ;
: (simd-vunpack-tail)      ( a   rep -- c )
    [ byte>rep-array ] [ widen-vector-rep [ rep-length ] [ '[ _ >rep-array ] ] bi ] bi
    [ tail-slice ] dip call( a' -- c' ) underlying>> ;
: (simd-with)              ( n rep -- v )
    [ rep-length swap '[ _ ] ] [ <rep-array> ] bi replicate-as
    underlying>> ;
: (simd-gather-2)          ( m n rep -- v ) <rep-array> [ 2 set-firstn-unsafe ] keep underlying>> ;
: (simd-gather-4)          ( m n o p rep -- v ) <rep-array> [ 4 set-firstn-unsafe ] keep underlying>> ;
: (simd-select)            ( a n rep -- x ) swapd byte>rep-array nth-unsafe ;

: alien-vector     ( c-ptr n rep -- value )
    [ swap <displaced-alien> ] dip rep-size memory>byte-array ;
: set-alien-vector ( value c-ptr n rep -- )
    [ swap <displaced-alien> swap ] dip rep-size memcpy ;

"compiler.cfg.intrinsics.simd" require
"compiler.tree.propagation.simd" require
"compiler.cfg.value-numbering.simd" require
