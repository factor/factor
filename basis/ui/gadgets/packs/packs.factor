! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences ui.gadgets ui.baseline-alignment
ui.baseline-alignment.private kernel math math.functions math.vectors
math.order math.rectangles namespaces accessors fry combinators arrays ;
IN: ui.gadgets.packs

TUPLE: pack < gadget
{ align initial: 0 } { fill initial: 0 } { gap initial: { 0 0 } } ;

<PRIVATE

: (packed-dims) ( gadget sizes -- list )
    swap [ dim>> ] [ fill>> ] bi '[ _ over v- _ v*n v+ ] map ;

: orient ( seq1 seq2 gadget -- seq )
    orientation>> '[ _ set-axis ] 2map ;

: packed-dims ( gadget sizes -- seq )
    [ (packed-dims) ] [ nip ] [ drop ] 2tri orient ;

: gap-locs ( sizes gap -- seq )
    [ { 0 0 } ] dip '[ v+ _ v+ ] accumulate nip ;

: numerically-aligned-locs ( sizes pack -- seq )
    [ align>> ] [ dim>> ] bi '[ [ _ _ ] dip v- [ * >integer ] with map ] map ;

: baseline-aligned-locs ( pack -- seq )
    children>> align-baselines [ 0 swap 2array ] map ;

: aligned-locs ( sizes pack -- seq )
    dup align>> +baseline+ eq?
    [ nip baseline-aligned-locs ]
    [ numerically-aligned-locs ]
    if ;

: packed-locs ( sizes pack -- seq )
    [ aligned-locs ] [ gap>> gap-locs ] [ nip ] 2tri orient ;

: round-dims ( seq -- newseq )
    [ { 0 0 } ] dip
    [ swap v- dup [ ceiling ] map [ swap v- ] keep ] map
    nip ;

PRIVATE>

: pack-layout ( pack sizes -- )
    [ round-dims packed-dims ] [ drop ] 2bi
    [ children>> [ (>>dim) ] 2each ]
    [ [ packed-locs ] [ children>> ] bi [ (>>loc) ] 2each ] 2bi ;

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
    [ [ children>> ] dip measure-height 0 swap 2array ] [ nip max-dim ] if ;

: pack-pref-dim ( pack sizes -- dim )
    [ max-pack-dim ]
    [ [ gap-dim ] [ dim-sum ] bi* v+ ]
    [ drop orientation>> ]
    2tri set-axis ;

M: pack pref-dim*
    dup children>> pref-dims pack-pref-dim ;

: vertical-baseline ( pack -- y )
    children>> [ f ] [ first baseline ] if-empty ;

: horizontal-baseline ( pack -- y )
    children>> dup pref-dims measure-metrics drop ;

: pack-cap-height ( pack -- n )
    children>> [ cap-height ] map ?supremum ;

PRIVATE>

M: pack baseline
    dup orientation>> {
        { vertical [ vertical-baseline ] }
        { horizontal [ horizontal-baseline ] }
    } case ;

M: pack cap-height pack-cap-height ;

M: pack layout*
    dup children>> pref-dims pack-layout ;

M: pack children-on ( rect gadget -- seq )
    [ orientation>> ] [ children>> ] bi
    [ fast-children-on ] keep <slice> ;
