! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays combinators grouping kernel locals math
math.matrices math.order multiline sequence-parser sequences
tools.continuations ;
IN: compression.run-length


: run-length-uncompress ( byte-array -- byte-array' )
    2 group [ first2 <array> ] map B{ } concat-as ;

