! Copyright (C) 2005, 2008 Slava Pestov, Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: sequences kernel accessors ;
IN: columns

! A column of a matrix
TUPLE: column seq col ;

C: <column> column

M: column virtual-seq seq>> ;
M: column virtual@ dup col>> -rot seq>> nth bounds-check ;
M: column length seq>> length ;

INSTANCE: column virtual-sequence
