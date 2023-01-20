! Copyright (C) 2005, 2010 Slava Pestov, Daniel Ehrenberg.
! See https://factorcode.org/license.txt for BSD license.
USING: sequences kernel accessors ;
IN: columns

! A column of a matrix
TUPLE: column seq col ;

C: <column> column

M: column virtual-exemplar seq>> ;
M: column virtual@ [ col>> swap ] [ seq>> ] bi nth bounds-check ;
M: column length seq>> length ;

INSTANCE: column virtual-sequence

: <flipped> ( seq -- seq' )
    dup empty? [ dup first length [ <column> ] with map-integers ] unless ;
