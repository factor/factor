! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.order namespaces accessors kernel layouts combinators
combinators.smart assocs sequences cpu.architecture ;
IN: compiler.cfg.stack-frame

TUPLE: stack-frame
{ params integer }
{ return integer }
{ total-size integer }
{ gc-root-size integer }
spill-counts ;

! Stack frame utilities
: param-base ( -- n )
    stack-frame get [ params>> ] [ return>> ] bi + ;

: spill-float-offset ( n -- offset )
    double-float-regs reg-size * ;

: spill-integer-base ( -- n )
    stack-frame get spill-counts>> double-float-regs [ swap at ] keep reg-size *
    param-base + ;

: spill-integer-offset ( n -- offset )
    cells spill-integer-base + ;

: spill-area-size ( stack-frame -- n )
    spill-counts>> [ swap reg-size * ] { } assoc>map sum ;

: gc-root-base ( -- n )
    stack-frame get spill-area-size
    param-base + ;

: gc-root-offset ( n -- n' ) gc-root-base + ;

: gc-roots-size ( live-registers live-spill-slots -- n )
    [ keys [ reg-class>> reg-size ] sigma ] bi@ + ;

: (stack-frame-size) ( stack-frame -- n )
    [
        {
            [ spill-area-size ]
            [ gc-root-size>> ]
            [ params>> ]
            [ return>> ]
        } cleave
    ] sum-outputs ;

: max-stack-frame ( frame1 frame2 -- frame3 )
    [ stack-frame new ] 2dip
        [ [ params>> ] bi@ max >>params ]
        [ [ return>> ] bi@ max >>return ]
        [ [ gc-root-size>> ] bi@ max >>gc-root-size ]
        2tri ;