! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes functors growable kernel math sequences
sequences.private functors2 ;
IN: vectors.functor

SAME-FUNCTOR: special-vector ( vector: name underlying: existing-class -- ) [[
    USING: classes growable kernel math sequences sequences.private
    specialized-arrays ;

    TUPLE: ${vector} { underlying ${underlying} } { length array-capacity } ;

    : >${vector} ( seq -- vector ) ${vector} new clone-like ; inline

    : <${vector}> ( capacity -- vector ) <${underlying}> 0 ${vector} boa ; inline

    M: ${vector} like
        drop dup ${vector} instance? [
            dup ${underlying} instance? [ dup length ${vector} boa ] [ >${vector} ] if
        ] unless ; inline

    M: ${vector} new-sequence drop [ <${underlying}> ] [ >fixnum ] bi ${vector} boa ; inline

    M: ${underlying} new-resizable drop <${vector}> ; inline

    M: ${vector} new-resizable drop <${vector}> ; inline

    M: ${vector} equal? over ${vector} instance? [ sequence= ] [ 2drop f ] if ;

    INSTANCE: ${vector} growable
]]
