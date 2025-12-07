! Copyright (C) 2005, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators kernel math math.order
math.vectors opengl sequences ui.baseline-alignment
ui.baseline-alignment.private ui.gadgets ;
IN: ui.gadgets.packs

TUPLE: pack < aligned-gadget
    { align initial: 0 }
    { fill initial: 0 }
    { gap initial: { 0 0 } } ;

<PRIVATE

: (packed-dims) ( gadget sizes -- list )
    swap [ dim>> ] [ fill>> ] bi '[ _ over v- _ v*n v+ ] map ;

: orient ( seq1 seq2 gadget -- seq )
    orientation>> '[ _ set-axis [ gl-round ] map ] 2map ;

: packed-dims ( gadget sizes -- seq )
    [ (packed-dims) ] [ nip ] [ drop ] 2tri orient ;

: gap-locs ( sizes gap -- seq )
    [ { 0 0 } ] dip '[ v+ _ v+ [ gl-round ] map ] accumulate nip ;

: numerically-aligned-locs ( sizes pack -- seq )
    [ align>> ] [ dim>> ] bi rot [ v- [ * ] with map ] 2with map ;

: baseline-aligned-locs ( pack -- seq )
    children>> align-baselines [ 0 swap 2array ] map ;

: aligned-locs ( sizes pack -- seq )
    dup align>> +baseline+ eq?
    [ nip baseline-aligned-locs ]
    [ numerically-aligned-locs ]
    if ;

: packed-locs ( sizes pack -- seq )
    [ aligned-locs ] [ gap>> gap-locs ] [ nip ] 2tri orient ;

PRIVATE>

: pack-layout ( pack sizes -- )
    [ packed-dims ] [ drop ] 2bi
    [ children>> [ dim<< ] 2each ]
    [ [ packed-locs ] [ children>> ] bi [ loc<< ] 2each ] 2bi ;

: <pack> ( orientation -- pack )
    pack new
        swap >>orientation ;

: <pile> ( -- pack ) vertical <pack> ;

: <filled-pile> ( -- pack ) <pile> 1 >>fill ;

: <shelf> ( -- pack ) horizontal <pack> ;

<PRIVATE

: gap-dim ( pack -- dim )
    [ gap>> ] [ children>> length 1 [-] ] bi v*n ;

: max-pack-dim ( pack sizes -- dim )
    over align>> +baseline+ eq?
    [ [ children>> ] dip measure-height 0 swap 2array ] [ nip max-dims ] if ;

: pack-pref-dim ( pack sizes -- dim )
    [ max-pack-dim ]
    [ [ gap-dim ] [ sum-dims ] bi* v+ ]
    [ drop orientation>> ]
    2tri set-axis ;

M: pack pref-dim*
    dup children>> pref-dims pack-pref-dim ;

: vertical-baseline ( pack -- y )
    children>> [ f ] [ first baseline ] if-empty ; inline

: horizontal-baseline ( pack -- y )
    children>> dup pref-dims measure-metrics drop ; inline

: pack-cap-height ( pack -- n/f )
    children>> [ cap-height ] map ?maximum ; inline

PRIVATE>

M: pack baseline*
    dup orientation>> {
        { vertical [ vertical-baseline ] }
        { horizontal [ horizontal-baseline ] }
    } case ;

M: pack cap-height* pack-cap-height ;

M: pack layout*
    dup children>> pref-dims pack-layout ;

M: pack children-on
    [ orientation>> ] [ children>> ] bi [ loc>> ] fast-children-on ;
