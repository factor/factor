! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences ui.gadgets kernel math math.functions
math.vectors math.order math.geometry.rect namespaces accessors
fry combinators arrays ;
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
    [ align>> ] [ dim>> ] bi '[ [ _ _ ] dip v- n*v ] map ;

: baseline-aligned-locs ( pack -- seq )
    children>> baseline-align [ 0 swap 2array ] map ;

: aligned-locs ( sizes pack -- seq )
    dup align>> +baseline+ eq?
    [ nip baseline-aligned-locs ]
    [ numerically-aligned-locs ]
    if ;

: packed-locs ( sizes pack -- seq )
    [ aligned-locs ] [ gap>> gap-locs ] [ nip ] 2tri orient ;

: round-dims ( seq -- newseq )
    [ { 0 0 } ] dip
    [ swap v- dup [ ceiling >fixnum ] map [ swap v- ] keep ] map
    nip ;

PRIVATE>

: pack-layout ( pack sizes -- )
    [ round-dims packed-dims ] [ drop ] 2bi
    [ children>> [ (>>dim) ] 2each ]
    [ [ packed-locs ] [ children>> ] bi [ (>>loc) ] 2each ] 2bi ;

: <pack> ( orientation -- pack )
    pack new-gadget
        swap >>orientation ;

: <pile> ( -- pack ) vertical <pack> ;

: <filled-pile> ( -- pack ) <pile> 1 >>fill ;

: <shelf> ( -- pack ) horizontal <pack> ;

<PRIVATE

: gap-dims ( gadget sizes -- seeq )
    [ gap>> ] [ [ length 1 [-] ] [ dim-sum ] bi ] bi* [ v*n ] dip v+ ;

: pack-pref-dim ( gadget sizes -- dim )
    [ nip max-dim ] [ gap-dims ] [ drop orientation>> ] 2tri set-axis ;

M: pack pref-dim*
    dup children>> pref-dims pack-pref-dim ;

: vertical-baseline ( pack -- y )
    children>> [ 0 ] [ first baseline ] if-empty ;

: horizontal-baseline ( pack -- y )
    children>> [ baseline ] [ max ] map-reduce ;

PRIVATE>

M: pack baseline
    dup orientation>> {
        { vertical [ vertical-baseline ] }
        { horizontal [ horizontal-baseline ] }
    } case ;

M: pack layout*
    dup children>> pref-dims pack-layout ;

M: pack children-on ( rect gadget -- seq )
    [ orientation>> ] [ children>> ] bi
    [ fast-children-on ] keep <slice> ;
