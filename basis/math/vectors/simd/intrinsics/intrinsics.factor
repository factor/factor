! (c)2009 Slava Pestov, Joe Groff bsd license
USING: accessors alien alien.c-types alien.data combinators
sequences.cords cpu.architecture fry generalizations kernel
libc locals math math.libm math.order math.ranges math.vectors
sequences sequences.private specialized-arrays vocabs.loader ;
QUALIFIED-WITH: alien.c-types c
SPECIALIZED-ARRAYS:
    c:char c:short c:int c:longlong
    c:uchar c:ushort c:uint c:ulonglong
    c:float c:double ;
IN: math.vectors.simd.intrinsics

: assert-positive ( x -- y ) ;

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

: [byte>rep-array] ( rep -- class )
    {
        { char-16-rep      [ [ byte-array>char-array      ] ] }
        { uchar-16-rep     [ [ byte-array>uchar-array     ] ] }
        { short-8-rep      [ [ byte-array>short-array     ] ] }
        { ushort-8-rep     [ [ byte-array>ushort-array    ] ] }
        { int-4-rep        [ [ byte-array>int-array       ] ] }
        { uint-4-rep       [ [ byte-array>uint-array      ] ] }
        { longlong-2-rep   [ [ byte-array>longlong-array  ] ] }
        { ulonglong-2-rep  [ [ byte-array>ulonglong-array ] ] }
        { float-4-rep      [ [ byte-array>float-array     ] ] }
        { double-2-rep     [ [ byte-array>double-array    ] ] }
    } case ; foldable

: [>rep-array] ( rep -- class )
    {
        { char-16-rep      [ [ >char-array      ] ] }
        { uchar-16-rep     [ [ >uchar-array     ] ] }
        { short-8-rep      [ [ >short-array     ] ] }
        { ushort-8-rep     [ [ >ushort-array    ] ] }
        { int-4-rep        [ [ >int-array       ] ] }
        { uint-4-rep       [ [ >uint-array      ] ] }
        { longlong-2-rep   [ [ >longlong-array  ] ] }
        { ulonglong-2-rep  [ [ >ulonglong-array ] ] }
        { float-4-rep      [ [ >float-array     ] ] }
        { double-2-rep     [ [ >double-array    ] ] }
    } case ; foldable

: [<rep-array>] ( rep -- class )
    {
        { char-16-rep      [ [ 16 (char-array)      ] ] }
        { uchar-16-rep     [ [ 16 (uchar-array)     ] ] }
        { short-8-rep      [ [  8 (short-array)     ] ] }
        { ushort-8-rep     [ [  8 (ushort-array)    ] ] }
        { int-4-rep        [ [  4 (int-array)       ] ] }
        { uint-4-rep       [ [  4 (uint-array)      ] ] }
        { longlong-2-rep   [ [  2 (longlong-array)  ] ] }
        { ulonglong-2-rep  [ [  2 (ulonglong-array) ] ] }
        { float-4-rep      [ [  4 (float-array)     ] ] }
        { double-2-rep     [ [  2 (double-array)    ] ] }
    } case ; foldable

: rep-tf-values ( rep -- t f )
    float-vector-rep? [ -1 bits>double 0.0 ] [ -1 0 ] if ;

: >rep-array ( a rep -- a' )
    [byte>rep-array] call( a -- a' ) ; inline
: 2>rep-array ( a b rep -- a' b' )
    [byte>rep-array] '[ _ call( a -- a' ) ] bi@ ; inline
: <rep-array> ( rep -- a' )
    [<rep-array>] call( -- a' ) ; inline

: components-map ( a rep quot -- c )
    [ >rep-array ] dip map underlying>> ; inline
: components-2map ( a b rep quot -- c )
    [ 2>rep-array ] dip 2map underlying>> ; inline
: components-reduce ( a rep quot -- x )
    [ >rep-array [ ] ] dip map-reduce ; inline

: bitwise-components-map ( a rep quot -- c )
    [ >bitwise-vector-rep >rep-array ] dip map underlying>> ; inline
: bitwise-components-2map ( a b rep quot -- c )
    [ >bitwise-vector-rep 2>rep-array ] dip 2map underlying>> ; inline
: bitwise-components-reduce ( a rep quot -- x )
    [ >bitwise-vector-rep >rep-array [ ] ] dip map-reduce ; inline

:: (vshuffle) ( a elts rep -- c )
    a rep >rep-array :> a'
    rep <rep-array> :> c'
    elts [| from to |
        from rep rep-length 1 - bitand
           a' nth-unsafe
        to c' set-nth-unsafe
    ] each-index
    c' underlying>> ; inline

PRIVATE>

: (simd-v+)                ( a b rep -- c ) [ + ] components-2map ;
: (simd-v-)                ( a b rep -- c ) [ - ] components-2map ;
: (simd-vneg)              ( a   rep -- c ) [ neg ] components-map ;
:: (simd-v+-)              ( a b rep -- c ) 
    a b rep 2>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    0  rep rep-length 1 -  2 <range> [| n |
        n     a' nth-unsafe n     b' nth-unsafe -
        n     c' set-nth-unsafe

        n 1 + a' nth-unsafe n 1 + b' nth-unsafe +
        n 1 + c' set-nth-unsafe
    ] each
    c' underlying>> ;
: (simd-vs+)               ( a b rep -- c )
    dup rep-component-type '[ + _ c-type-clamp ] components-2map ;
: (simd-vs-)               ( a b rep -- c )
    dup rep-component-type '[ - _ c-type-clamp ] components-2map ;
: (simd-vs*)               ( a b rep -- c )
    dup rep-component-type '[ * _ c-type-clamp ] components-2map ;
: (simd-v*)                ( a b rep -- c ) [ * ] components-2map ;
: (simd-v*high)            ( a b rep -- c )
    dup rep-component-type heap-size -8 * '[ * _ shift ] components-2map ;
:: (simd-v*hs+)            ( a b rep -- c )
    rep widen-vector-rep signed-rep :> wide-rep
    wide-rep rep-component-type :> wide-type
    a rep >rep-array 2 <groups> :> a'
    b rep >rep-array 2 <groups> :> b'
    a' b' [
        [ [ first  ] bi@ * ]
        [ [ second ] bi@ * ] 2bi +
        wide-type c-type-clamp
    ] wide-rep <rep-array> 2map-as ;
: (simd-v/)                ( a b rep -- c ) [ / ] components-2map ;
: (simd-vavg)              ( a b rep -- c ) [ + 2 / ] components-2map ;
: (simd-vmin)              ( a b rep -- c ) [ min ] components-2map ;
: (simd-vmax)              ( a b rep -- c ) [ max ] components-2map ;
: (simd-v.)                ( a b rep -- n )
    [ 2>rep-array [ [ first ] bi@ * ] 2keep ] keep
    1 swap rep-length [a,b) [ '[ _ swap nth-unsafe ] bi@ * + ] with with each ;
: (simd-vsqrt)             ( a   rep -- c ) [ fsqrt ] components-map ;
: (simd-vsad)              ( a b rep -- n ) 2>rep-array [ - abs ] [ + ] 2map-reduce ;
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
: (simd-hlshift)           ( a n rep -- c )
    drop head-slice* 16 0 pad-head ;
: (simd-hrshift)           ( a n rep -- c )
    drop tail-slice 16 0 pad-tail ;
: (simd-vshuffle-elements) ( a n rep -- c ) [ rep-length 0 pad-tail ] keep (vshuffle) ;
: (simd-vshuffle-bytes)    ( a b rep -- c ) drop uchar-16-rep (vshuffle) ;
:: (simd-vmerge-head)      ( a b rep -- c )
    a b rep 2>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    rep rep-length 2 /i iota [| n |
        n a' nth-unsafe n 2 *     c' set-nth-unsafe
        n b' nth-unsafe n 2 * 1 + c' set-nth-unsafe
    ] each
    c' underlying>> ;
:: (simd-vmerge-tail)      ( a b rep -- c )
    a b rep 2>rep-array :> ( a' b' )
    rep <rep-array> :> c'
    rep rep-length 2 /i :> len
    len iota [| n |
        n len + a' nth-unsafe n 2 *     c' set-nth-unsafe
        n len + b' nth-unsafe n 2 * 1 + c' set-nth-unsafe
    ] each
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
: (simd-v>float)           ( a   rep -- c )
    [ >rep-array [ >float ] ] [ >float-vector-rep <rep-array> ] bi map-as underlying>> ;
: (simd-v>integer)         ( a   rep -- c )
    [ >rep-array [ >integer ] ] [ >int-vector-rep <rep-array> ] bi map-as underlying>> ;
: (simd-vpack-signed)      ( a b rep -- c )
    [ 2>rep-array cord-append ]
    [ narrow-vector-rep [ <rep-array> ] [ rep-component-type ] bi ] bi
    '[ _ c-type-clamp ] swap map-as underlying>> ;
: (simd-vpack-unsigned)    ( a b rep -- c )
    [ 2>rep-array cord-append ]
    [ narrow-vector-rep >uint-vector-rep [ <rep-array> ] [ rep-component-type ] bi ] bi
    '[ _ c-type-clamp ] swap map-as underlying>> ;
: (simd-vunpack-head)      ( a   rep -- c ) 
    [ >rep-array ] [ widen-vector-rep [ rep-length ] [ [>rep-array] ] bi ] bi
    [ head-slice ] dip call( a' -- c' ) underlying>> ;
: (simd-vunpack-tail)      ( a   rep -- c )
    [ >rep-array ] [ widen-vector-rep [ rep-length ] [ [>rep-array] ] bi ] bi
    [ tail-slice ] dip call( a' -- c' ) underlying>> ;
: (simd-with)              (   n rep -- v )
    [ rep-length iota swap '[ _ ] ] [ <rep-array> ] bi replicate-as 
    underlying>> ;
: (simd-gather-2)          ( m n rep -- v ) <rep-array> [ 2 set-firstn ] keep underlying>> ;
: (simd-gather-4)          ( m n o p rep -- v ) <rep-array> [ 4 set-firstn ] keep underlying>> ;
: (simd-select)            ( a n rep -- x ) [ swap ] dip >rep-array nth-unsafe ;

: alien-vector     (       c-ptr n rep -- value )
    [ swap <displaced-alien> ] dip rep-size memory>byte-array ;
: set-alien-vector ( value c-ptr n rep --       )
    [ swap <displaced-alien> swap ] dip rep-size memcpy ;

"compiler.cfg.intrinsics.simd" require
"compiler.tree.propagation.simd" require
"compiler.cfg.value-numbering.simd" require

