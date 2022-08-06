! (c)2010 Joe Groff bsd license
USING: accessors kernel locals math papier.map sequences typed ;
IN: papier.sprites

TUPLE: animation-frame
    { slab-frame fixnum }
    { duration fixnum } ;

TUPLE: animation-cursor
    animation
    { frame fixnum }
    { time fixnum } ;

: <animation-cursor> ( animation -- cursor )
    0 0 animation-cursor boa ; inline

TYPED:: inc-cursor ( cursor: animation-cursor -- )
    cursor [ time>> ] [ frame>> ] [ animation>> ] tri :> ( time# frame# animation )
    frame# animation nth :> frame
    time# 1 + :> time'
    time' frame duration>> = [
        frame# 1 + :> frame'
        frame' animation length = [ 0 ] [ frame' ] if :> frame''
        cursor
            0 >>time
            frame'' >>frame
            drop
    ] [
        cursor time' >>time drop
    ] if ;

TYPED: cursor-frame ( cursor: animation-cursor -- frame: fixnum )
    [ frame>> ] [ animation>> nth ] bi slab-frame>> ; inline

: cursor++ ( cursor -- frame )
    [ cursor-frame ] [ inc-cursor ] bi ; inline

: ++cursor ( cursor -- frame )
    [ inc-cursor ] [ cursor-frame ] bi ; inline

TUPLE: sprite < slab
    animations
    { cursor animation-cursor } ;

: <sprite> ( -- sprite ) sprite new ; inline

: start-animation ( sprite animation -- sprite )
    <animation-cursor> [ >>cursor ] keep
    cursor-frame >>frame ; inline

: switch-animation ( sprite animation -- sprite )
    2dup swap cursor>> animation>> eq?
    [ drop ] [ start-animation ] if ; inline

: set-up-sprite ( animations sprite -- sprite )
    swap
    [ >>animations ] keep
    first start-animation ; inline

: inc-sprite ( sprite -- sprite )
    dup cursor>> ++cursor >>frame ; inline
