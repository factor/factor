! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes functors growable kernel math sequences
sequences.private ;
IN: vectors.functor

<FUNCTOR: define-vector ( V A <A> -- )

<V> DEFINES <${V}>
>V  DEFINES >${V}

WHERE

TUPLE: V { underlying A } { length array-capacity } ;

: <V> ( capacity -- vector ) <A> 0 V boa ; inline

M: V like
    drop dup V instance? [
        dup A instance? [ dup length V boa ] [ >V ] if
    ] unless ; inline

M: V new-sequence drop [ <A> ] [ >fixnum ] bi V boa ; inline

M: A new-resizable drop <V> ; inline

M: V new-resizable drop <V> ; inline

M: V equal? over V instance? [ sequence= ] [ 2drop f ] if ;

: >V ( seq -- vector ) V new clone-like ; inline

INSTANCE: V growable

;FUNCTOR>
