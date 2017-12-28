! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes functors growable kernel math sequences
sequences.private functors2 ;
IN: vectors.functor

! VECTORIZED: bit bit-array <bit-array> ! bit is not necessarily a word
! VECTORIZED: int int-array <int-array> ! int is a word already

SAME-FUNCTOR: vectorized ( type: name underlying: existing-word constructor: existing-word -- ) [[
    USING: classes growable kernel math sequences sequences.private ;

    <<
    TUPLE: ${type}-vector { underlying ${underlying} } { length array-capacity } ;
    >>

    : >${type}-vector ( seq -- vector ) ${type}-vector new clone-like ; inline

    : <${type}-vector> ( capacity -- vector ) ${constructor} 0 ${type}-vector boa ; inline

    M: ${type}-vector like
        drop dup ${type}-vector instance? [
            dup ${underlying} instance? [ dup length ${type}-vector boa ] [ >${type}-vector ] if
        ] unless ; inline

    M: ${type}-vector new-sequence drop [ ${constructor} ] [ >fixnum ] bi ${type}-vector boa ; inline

    M: ${underlying} new-resizable drop <${type}-vector> ; inline

    M: ${type}-vector new-resizable drop <${type}-vector> ; inline

    M: ${type}-vector equal? over ${type}-vector instance? [ sequence= ] [ 2drop f ] if ;

    INSTANCE: ${type}-vector growable
]]
