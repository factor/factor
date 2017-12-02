! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes functors growable kernel math sequences
sequences.private functors2 ;
IN: vectors.functor

FUNCTOR: special-vector ( T: existing-word -- ) [[
USING: classes growable kernel math sequences sequences.private
specialized-arrays ;

SPECIALIZED-ARRAY: ${T}

TUPLE: ${T}-vector { underlying ${T}-array } { length array-capacity } ;

: >${T}-vector ( seq -- vector ) ${T}-vector new clone-like ; inline

: <${T}-vector> ( capacity -- vector ) <${T}-array> 0 ${T}-vector boa ; inline

M: ${T}-vector like
    drop dup ${T}-vector instance? [
        dup ${T}-array instance? [ dup length ${T}-vector boa ] [ >${T}-vector ] if
    ] unless ; inline

M: ${T}-vector new-sequence drop [ <${T}-array> ] [ >fixnum ] bi ${T}-vector boa ; inline

M: ${T}-array new-resizable drop <${T}-vector> ; inline

M: ${T}-vector new-resizable drop <${T}-vector> ; inline

M: ${T}-vector equal? over ${T}-vector instance? [ sequence= ] [ 2drop f ] if ;

INSTANCE: ${T}-vector growable

]]
