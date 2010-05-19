! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: math math.order namespaces accessors kernel layouts
combinators assocs sequences cpu.architecture
words compiler.cfg.instructions ;
IN: compiler.cfg.stack-frame

TUPLE: stack-frame
{ params integer }
{ local-allot integer }
{ spill-area-size integer }
{ total-size integer } ;

! Stack frame utilities
: local-allot-offset ( n -- offset )
    stack-frame get params>> + ;

: spill-offset ( n -- offset )
    stack-frame get [ params>> ] [ local-allot>> ] bi + + ;

: (stack-frame-size) ( stack-frame -- n )
    [ params>> ] [ local-allot>> ] [ spill-area-size>> ] tri + + ;

: max-stack-frame ( frame1 frame2 -- frame3 )
    [ stack-frame new ] 2dip
    {
        [ [ params>> ] bi@ max >>params ]
        [ [ local-allot>> ] bi@ max >>local-allot ]
        [ [ spill-area-size>> ] bi@ max >>spill-area-size ]
    } 2cleave ;
