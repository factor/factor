! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private growable
prettyprint.custom kernel words classes math parser ;
IN: specialized-vectors.functor

FUNCTOR: define-vector ( T -- )

A   IS      ${T}-array
<A> IS      <${A}>

V   DEFINES-CLASS ${T}-vector
<V> DEFINES <${V}>
>V  DEFINES >${V}
V{  DEFINES ${V}{

WHERE

TUPLE: V { underlying A } { length array-capacity } ;

: <V> ( capacity -- vector ) <A> 0 V boa ; inline

M: V like
    drop dup V instance? [
        dup A instance? [ dup length V boa ] [ >V ] if
    ] unless ;

M: V new-sequence drop [ <A> ] [ >fixnum ] bi V boa ;

M: A new-resizable drop <V> ;

M: V equal? over V instance? [ sequence= ] [ 2drop f ] if ;

: >V ( seq -- vector ) V new clone-like ; inline

M: V pprint-delims drop \ V{ \ } ;

M: V >pprint-sequence ;

M: V pprint* pprint-object ;

: V{ \ } [ >V ] parse-literal ; parsing

INSTANCE: V growable

;FUNCTOR
