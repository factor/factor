! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.order namespaces accessors kernel layouts combinators
combinators.smart assocs sequences cpu.architecture ;
IN: compiler.cfg.stack-frame

TUPLE: stack-frame
{ params integer }
{ return integer }
{ total-size integer }
{ spill-area-size integer }
{ calls-vm? boolean } ;

! Stack frame utilities
: param-base ( -- n )
    stack-frame get [ params>> ] [ return>> ] bi + ;

: spill-offset ( n -- offset )
    param-base + ;

: (stack-frame-size) ( stack-frame -- n )
    [
        [ params>> ] [ return>> ] [ spill-area-size>> ] tri
    ] sum-outputs ;

: max-stack-frame ( frame1 frame2 -- frame3 )
    [ stack-frame new ] 2dip
    {
        [ [ params>> ] bi@ max >>params ]
        [ [ return>> ] bi@ max >>return ]
        [ [ calls-vm?>> ] bi@ or >>calls-vm? ]
    } 2cleave ;