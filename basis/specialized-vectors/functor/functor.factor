! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: functors sequences sequences.private growable
prettyprint.custom kernel words classes math parser ;
IN: specialized-vectors.functor

FUNCTOR: define-vector ( T -- )

A   IS      ${T}-array
<A> IS      <${A}>

V   DEFINES ${T}-vector
<V> DEFINES <${V}>
>V  DEFINES >${V}
V{  DEFINES ${V}{

WHERE

TUPLE: V { underlying A } { length array-capacity } ;

: <V> <A> execute 0 V boa ; inline

M: V like
    drop dup V instance? [
        dup A instance? [ dup length V boa ] [ >V execute ] if
    ] unless ;

M: V new-sequence drop [ <A> execute ] [ >fixnum ] bi V boa ;

M: A new-resizable drop <V> execute ;

M: V equal? over V instance? [ sequence= ] [ 2drop f ] if ;

: >V V new clone-like ; inline

M: V pprint-delims drop V{ \ } ;

M: V >pprint-sequence ;

M: V pprint* pprint-object ;

: V{ \ } [ >V execute ] parse-literal ; parsing

INSTANCE: V growable

;FUNCTOR
