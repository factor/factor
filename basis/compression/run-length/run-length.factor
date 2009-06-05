! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays grouping sequences ;
IN: compression.run-length

: run-length-uncompress ( byte-array -- byte-array' )
    2 group [ first2 <array> ] map concat ;
