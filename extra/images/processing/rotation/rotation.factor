! Copyright (C) 2009 Kobi Lurie.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators grouping images kernel math
sequences ;
IN: images.processing.rotation

ERROR: unsupported-rotation degrees ;

<PRIVATE

: rotate-90 ( seq^3 -- seq^3 ) flip [ reverse ] map ;
: rotate-180 ( seq^3 -- seq^3 ) reverse [ reverse ] map ;
: rotate-270 ( seq^3 -- seq^3 ) flip reverse ;

: (rotate) ( seq n -- seq' )
    {
        { 0 [ ] }
        { 90 [ rotate-90 ] }
        { 180 [ rotate-180 ] }
        { 270 [ rotate-270 ] }
        [ unsupported-rotation ]
    } case ;

: rows-remove-pad ( byte-rows -- pixels' )
    [ dup length 4 mod head* ] map ; 

: row-length ( image -- n ) 
    [ bitmap>> length ] [ dim>> second ] bi /i ;

: image>byte-rows ( image -- byte-rows )
    [ bitmap>> ] [ row-length ] bi group rows-remove-pad ;

: (separate-to-pixels) ( byte-rows image -- pixel-rows )
    bytes-per-pixel '[ _ group ] map ;

: image>pixel-rows ( image -- pixel-rows )
    [ image>byte-rows ] keep (separate-to-pixels) ;
 
: flatten-table ( seq^3 -- seq )
    [ concat ] map concat ;

: ?reverse-dimensions ( image n -- )
    { 270 90 } member? [ [ reverse ] change-dim ] when drop ;

:  normalize-degree ( n -- n' ) 360 rem ;

: processing-effect ( image quot -- image' )
    '[ image>pixel-rows @ flatten-table ] [ bitmap<< ] [ ] tri ; inline

:: rotate' ( image n -- image )
    n normalize-degree :> n'
    image image>pixel-rows :> pixel-table
    image n' ?reverse-dimensions
    pixel-table n' (rotate) :> table-rotated
    image table-rotated flatten-table >>bitmap ;

PRIVATE>

: rotate ( image n -- image' )
    normalize-degree
    [ '[ _ (rotate) ] processing-effect ] [ ?reverse-dimensions ] 2bi ;

: reflect-y-axis ( image -- image ) 
    [ [ reverse ] map ] processing-effect ;

: reflect-x-axis ( image -- image ) 
    [ reverse ] processing-effect ;
