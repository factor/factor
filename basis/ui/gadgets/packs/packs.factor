! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences ui.gadgets kernel math math.functions
math.vectors math.order math.geometry.rect namespaces accessors
fry ;
IN: ui.gadgets.packs

TUPLE: pack < gadget
{ align initial: 0 } { fill initial: 0 } { gap initial: { 0 0 } } ;

: packed-dim-2 ( gadget sizes -- list )
    swap [ dim>> ] [ fill>> ] bi '[ _ over v- _ v*n v+ ] map ;

: orient ( seq1 seq2 gadget -- seq )
    orientation>> '[ _ set-axis ] 2map ;

: packed-dims ( gadget sizes -- seq )
    [ packed-dim-2 ] [ nip ] [ drop ] 2tri orient ;

: gap-locs ( gap sizes -- seq )
    { 0 0 } [ v+ over v+ ] accumulate 2nip ;

: aligned-locs ( gadget sizes -- seq )
    [ [ [ align>> ] [ dim>> ] bi ] dip v- n*v ] with map ;

: packed-locs ( gadget sizes -- seq )
    [ aligned-locs ] [ [ gap>> ] dip gap-locs ] [ drop ] 2tri orient ;

: round-dims ( seq -- newseq )
    { 0 0 } swap
    [ swap v- dup [ ceiling >fixnum ] map [ swap v- ] keep ] map
    nip ;

: pack-layout ( pack sizes -- )
    round-dims over children>>
    [ dupd packed-dims ] dip
    [ [ (>>dim) ] 2each ]
    [ [ packed-locs ] dip [ (>>loc) ] 2each ] 2bi ;

: <pack> ( orientation -- pack )
    pack new-gadget
        swap >>orientation ;

: <pile> ( -- pack ) { 0 1 } <pack> ;

: <filled-pile> ( -- pack ) <pile> 1 >>fill ;

: <shelf> ( -- pack ) { 1 0 } <pack> ;

: gap-dims ( sizes gadget -- seeq )
    [ [ dim-sum ] [ length 1 [-] ] bi ] [ gap>> ] bi* n*v v+ ;

: pack-pref-dim ( gadget sizes -- dim )
    [ nip max-dim ]
    [ swap gap-dims ]
    [ drop orientation>> ]
    2tri set-axis ;

M: pack pref-dim*
    dup children>> pref-dims pack-pref-dim ;

M: pack layout*
    dup children>> pref-dims pack-layout ;

M: pack children-on ( rect gadget -- seq )
    dup orientation>> swap children>>
    [ fast-children-on ] keep <slice> ;
