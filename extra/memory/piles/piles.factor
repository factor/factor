! (c)2009 Joe Groff bsd license
USING: accessors alien destructors kernel libc math ;
IN: memory.piles

TUPLE: pile
    { underlying c-ptr }
    { size integer }
    { offset integer } ;

ERROR: not-enough-pile-space pile ;

M: pile dispose
    [ [ free ] when* f ] change-underlying drop ;

: <pile> ( size -- pile )
    [ malloc ] keep 0 pile boa ;

: pile-empty ( pile -- )
    0 >>offset drop ;

: pile-alloc ( pile size -- alien )
    [
        [ [ ] [ size>> ] [ offset>> ] tri ] dip +
        < [ not-enough-pile-space ] [ drop ] if
    ] [
        drop [ offset>> ] [ underlying>> ] bi <displaced-alien>
    ] [
        [ + ] curry change-offset drop
    ] 2tri ;

: pile-align ( pile align -- pile )
    [ align ] curry change-offset ;
    
